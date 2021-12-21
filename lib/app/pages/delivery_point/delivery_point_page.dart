import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/pages/delivery_point_order/delivery_point_order_page.dart';
import 'package:delman/app/pages/point_address/point_address_page.dart';
import 'package:delman/app/pages/app/app_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

part 'delivery_point_state.dart';
part 'delivery_point_view_model.dart';

class DeliveryPointPage extends StatelessWidget {
  final DeliveryPoint deliveryPoint;

  DeliveryPointPage({
    Key? key,
    required this.deliveryPoint
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryPointViewModel>(
      create: (context) => DeliveryPointViewModel(
        context,
        deliveryPoint: deliveryPoint
      ),
      child: _DeliveryPointView(),
    );
  }
}

class _DeliveryPointView extends StatefulWidget {
  @override
  _DeliveryPointViewState createState() => _DeliveryPointViewState();
}

class _DeliveryPointViewState extends State<_DeliveryPointView> {
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryPointViewModel, DeliveryPointState>(
      builder: (context, state) {
        DeliveryPointViewModel vm = context.read<DeliveryPointViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: Text('Точка ${vm.deliveryPoint.seq}')
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  children: [
                    InfoRow(
                      title: const Text(Strings.address),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => PointAddressPage(deliveryPoint: vm.deliveryPoint)
                            )
                          );
                        },
                        child: ExpandingText(vm.deliveryPoint.addressName, style: const TextStyle(color: Colors.blue)),
                      )
                    ),
                    ListTile(
                      leading: const Text(Strings.planArrival),
                      trailing: Text(Format.timeStr(vm.deliveryPoint.planArrival)),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8)
                    ),
                    ListTile(
                      leading: const Text(Strings.factArrival),
                      trailing: vm.deliveryPoint.inProgress ?
                        Text(Format.timeStr(vm.deliveryPoint.factArrival)) :
                        state is DeliveryPointInProgress ?
                          const SizedBox(child: CircularProgressIndicator()) :
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                              primary: Colors.blue
                            ),
                            child: const Text('Отметить'),
                            onPressed: () => vm.arrive(),
                          ),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8)
                    ),
                    ListTile(
                      leading: const Text(Strings.factDeparture),
                      trailing: Text(Format.timeStr(vm.deliveryPoint.factDeparture)),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8)
                    ),
                    vm.deliveryPointOrders.isEmpty ? Container() : ExpansionTile(
                      title: const Text('Доставка'),
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      children: _buildDeliveryTiles(context)
                    ),
                    vm.pickupPointOrders.isEmpty ? Container() : ExpansionTile(
                      title: const Text('Забор'),
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      children: _buildPickupTiles(context)
                    )
                  ]
                )
              )
            ]
          )
        );
      },
      listener: (context, state) {
        if (state is DeliveryPointOrderDataCopied) {
          showMessage(state.message);
        } else if (state is DeliveryPointArrivalSaved) {
          showMessage(state.message);
        } else if (state is DeliveryPointFailure) {
          showMessage(state.message);
        }
      },
    );
  }

  List<Widget> _buildDeliveryTiles(BuildContext context) {
    DeliveryPointViewModel vm = context.read<DeliveryPointViewModel>();

    return [
      InfoRow(title: const Text('ИМ'), trailing: Text(vm.deliveryPoint.sellerName ?? '')),
      InfoRow(title: const Text('Покупатель'), trailing: Text(vm.deliveryPoint.buyerName ?? '')),
      InfoRow(
        title: const Text('Телефон'),
        trailing: GestureDetector(
          onTap: vm.callPhone,
          child: Text(vm.deliveryPoint.phone ?? '', style: const TextStyle(color: Colors.blue))
        )
      ),
      InfoRow(title: const Text('Доставка'), trailing: Text(vm.deliveryPoint.deliveryTypeName ?? '')),
      InfoRow(title: const Text('Оплата'), trailing: Text(vm.deliveryPoint.paymentTypeName ?? '')),
      const InfoRow(title: Text('Заказы')),
      ...vm.deliveryPointOrders.map<Widget>((e) => _buildOrderTile(context, e)).toList()
    ];
  }

  List<Widget> _buildPickupTiles(BuildContext context) {
    DeliveryPointViewModel vm = context.read<DeliveryPointViewModel>();

    return [
      InfoRow(title: const Text('ИМ'), trailing: Text(vm.deliveryPoint.pickupSellerName ?? '')),
      InfoRow(title: const Text('Отправитель'), trailing: Text(vm.deliveryPoint.senderName ?? '')),
      InfoRow(
        title: const Text('Телефон'),
        trailing: GestureDetector(
          onTap: vm.callPhone,
          child: Text(vm.deliveryPoint.senderPhone ?? '', style: const TextStyle(color: Colors.blue))
        )
      ),
      const InfoRow(title: Text('Заказы')),
      ...vm.pickupPointOrders.map<Widget>((e) => _buildOrderTile(context, e)).toList()
    ];
  }

  Widget _buildOrderTile(BuildContext context, DeliveryPointOrder deliveryPointOrder) {
    DeliveryPointViewModel vm = context.read<DeliveryPointViewModel>();
    Order order = vm.getOrder(deliveryPointOrder);

    return ListTile(
      title: Text('Заказ ${order.trackingNumber}', style: const TextStyle(fontSize: 14)),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        onPressed: () => vm.copyOrderInfo(order),
        tooltip: 'Копировать',
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => DeliveryPointOrderPage(deliveryPointOrder: deliveryPointOrder)
          )
        );
      },
    );
  }
}
