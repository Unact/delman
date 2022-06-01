import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery, Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/constants/strings.dart';
import '/app/entities/entities.dart';
import '/app/data/database.dart';
import '/app/pages/delivery_point_order/delivery_point_order_page.dart';
import '/app/pages/point_address/point_address_page.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/services/api.dart';
import '/app/utils/format.dart';
import '/app/utils/geo_loc.dart';
import '/app/utils/misc.dart';
import '/app/widgets/widgets.dart';

part 'delivery_point_state.dart';
part 'delivery_point_view_model.dart';

class DeliveryPointPage extends StatelessWidget {
  final DeliveryPointExResult deliveryPointEx;

  DeliveryPointPage({
    Key? key,
    required this.deliveryPointEx
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryPointViewModel>(
      create: (context) => DeliveryPointViewModel(
        context,
        deliveryPointEx: deliveryPointEx
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
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryPointViewModel, DeliveryPointState>(
      builder: (context, state) {
        DeliveryPointViewModel vm = context.read<DeliveryPointViewModel>();
        DeliveryPoint deliveryPoint = state.deliveryPointEx.dp;

        return Scaffold(
          appBar: AppBar(
            title: Text('Точка ${deliveryPoint.seq}')
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
                              builder: (BuildContext context) => PointAddressPage(deliveryPoint: state.deliveryPointEx)
                            )
                          );
                        },
                        child: ExpandingText(
                          deliveryPoint.addressName,
                          style: const TextStyle(color: Colors.blue)
                        ),
                      )
                    ),
                    ListTile(
                      leading: const Text(Strings.planArrival),
                      trailing: Text(Format.timeStr(deliveryPoint.planArrival)),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8)
                    ),
                    ListTile(
                      leading: const Text(Strings.factArrival),
                      trailing: state.deliveryPointEx.dp.factArrival != null ?
                        Text(Format.timeStr(deliveryPoint.factArrival)) :
                        state.status.isInProgress ?
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
                      trailing: Text(Format.timeStr(deliveryPoint.factDeparture)),
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8)
                    ),
                    state.deliveryOrders.isEmpty ? Container() : ExpansionTile(
                      title: const Text('Доставка'),
                      initiallyExpanded: true,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                      children: _buildDeliveryTiles(context)
                    ),
                    state.pickupPointOrders.isEmpty ? Container() : ExpansionTile(
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
        switch (state.status) {
          case DeliveryPointStateStatus.orderDataCopied:
          case DeliveryPointStateStatus.arrivalSaved:
          case DeliveryPointStateStatus.failure:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            break;
          default:
        }
      },
    );
  }

  List<Widget> _buildDeliveryTiles(BuildContext context) {
    DeliveryPointViewModel vm = context.read<DeliveryPointViewModel>();
    DeliveryPoint deliveryPoint = vm.state.deliveryPointEx.dp;

    return [
      InfoRow(title: const Text('ИМ'), trailing: Text(deliveryPoint.sellerName ?? '')),
      InfoRow(title: const Text('Покупатель'), trailing: Text(deliveryPoint.buyerName ?? '')),
      InfoRow(
        title: const Text('Телефон'),
        trailing: GestureDetector(
          onTap: vm.callPhone,
          child: Text(deliveryPoint.phone ?? '', style: const TextStyle(color: Colors.blue))
        )
      ),
      InfoRow(title: const Text('Доставка'), trailing: Text(deliveryPoint.deliveryTypeName ?? '')),
      InfoRow(title: const Text('Оплата'), trailing: Text(deliveryPoint.paymentTypeName ?? '')),
      const InfoRow(title: Text('Заказы')),
      ...vm.state.deliveryOrders.map<Widget>((e) => _buildOrderTile(context, e)).toList()
    ];
  }

  List<Widget> _buildPickupTiles(BuildContext context) {
    DeliveryPointViewModel vm = context.read<DeliveryPointViewModel>();
    DeliveryPoint deliveryPoint = vm.state.deliveryPointEx.dp;

    return [
      InfoRow(title: const Text('ИМ'), trailing: Text(deliveryPoint.pickupSellerName ?? '')),
      InfoRow(title: const Text('Отправитель'), trailing: Text(deliveryPoint.senderName ?? '')),
      InfoRow(
        title: const Text('Телефон'),
        trailing: GestureDetector(
          onTap: vm.callPhone,
          child: Text(deliveryPoint.senderPhone ?? '', style: const TextStyle(color: Colors.blue))
        )
      ),
      const InfoRow(title: Text('Заказы')),
      ...vm.state.pickupPointOrders.map<Widget>((e) => _buildOrderTile(context, e)).toList()
    ];
  }

  Widget _buildOrderTile(BuildContext context, DeliveryPointOrderExResult deliveryPointOrderEx) {
    DeliveryPointViewModel vm = context.read<DeliveryPointViewModel>();
    Order order = deliveryPointOrderEx.o;

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
            builder: (BuildContext context) => DeliveryPointOrderPage(deliveryPointOrderEx: deliveryPointOrderEx)
          )
        );
      },
    );
  }
}
