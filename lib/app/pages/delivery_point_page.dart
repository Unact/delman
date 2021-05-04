import 'package:delman/app/pages/point_address_page.dart';
import 'package:delman/app/view_models/point_address_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/pages/order_page.dart';
import 'package:delman/app/view_models/delivery_point_view_model.dart';
import 'package:delman/app/view_models/order_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

class DeliveryPointPage extends StatefulWidget {
  const DeliveryPointPage({Key key}) : super(key: key);

  @override
  _DeliveryPointPageState createState() => _DeliveryPointPageState();
}

class _DeliveryPointPageState extends State<DeliveryPointPage> {
  DeliveryPointViewModel _deliveryPointViewModel;

  @override
  void initState() {
    super.initState();

    _deliveryPointViewModel = context.read<DeliveryPointViewModel>();
    _deliveryPointViewModel.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _deliveryPointViewModel.removeListener(this.vmListener);
    super.dispose();
  }

  void vmListener() {
    switch (_deliveryPointViewModel.state) {
      case DeliveryPointState.Failure:
      case DeliveryPointState.ArrivalSaved:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_deliveryPointViewModel.message)));

        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryPointViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Точка ${vm.deliveryPoint.seq}')
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(top: 24, bottom: 24),
                  children: [
                    InfoRow(
                      title: Text(Strings.address),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => ChangeNotifierProvider<PointAddressViewModel>(
                                create: (context) => PointAddressViewModel(
                                  context: context,
                                  deliveryPoint: vm.deliveryPoint
                                ),
                                child: PointAddressPage(),
                              )
                            )
                          );
                        },
                        child: ExpandingText(vm.deliveryPoint.addressName, style: TextStyle(color: Colors.blue)),
                      )
                    ),
                    ListTile(
                      leading: Text(Strings.planArrival),
                      trailing: Text(Format.timeStr(vm.deliveryPoint.planArrival)),
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8)
                    ),
                    ListTile(
                      leading: Text(Strings.factArrival),
                      trailing: vm.deliveryPoint.inProgress ?
                        Text(Format.timeStr(vm.deliveryPoint.factArrival)) :
                        vm.state == DeliveryPointState.InProgress ?
                          SizedBox(child: CircularProgressIndicator()) :
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
                              primary: Colors.blue
                            ),
                            child: Text('Отметить'),
                            onPressed: () => vm.arrive(),
                          ),
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8)
                    ),
                    ListTile(
                      leading: Text(Strings.factDeparture),
                      trailing: Text(Format.timeStr(vm.deliveryPoint.factDeparture)),
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8)
                    ),
                    vm.deliveryOrders.isEmpty ? Container() : ExpansionTile(
                      title: Text('Доставка'),
                      initiallyExpanded: true,
                      tilePadding: EdgeInsets.symmetric(horizontal: 8),
                      children: _buildDeliveryTiles(context)
                    ),
                    vm.pickupOrders.isEmpty ? Container() : ExpansionTile(
                      title: Text('Забор'),
                      initiallyExpanded: true,
                      tilePadding: EdgeInsets.symmetric(horizontal: 8),
                      children: _buildPickupTiles(context)
                    )
                  ]
                )
              )
            ]
          )
        );
      }
    );
  }

  List<Widget> _buildDeliveryTiles(BuildContext context) {
    DeliveryPointViewModel vm = Provider.of<DeliveryPointViewModel>(context);

    return [
      InfoRow(title: Text('ИМ'), trailing: Text(vm.deliveryPoint.sellerName ?? '')),
      InfoRow(title: Text('Покупатель'), trailing: Text(vm.deliveryPoint.buyerName ?? '')),
      InfoRow(
        title: Text('Телефон'),
        trailing: GestureDetector(
          onTap: vm.callPhone,
          child: Text(vm.deliveryPoint.phone ?? '', style: TextStyle(color: Colors.blue))
        )
      ),
      InfoRow(title: Text('Доставка'), trailing: Text(vm.deliveryPoint.deliveryTypeName ?? '')),
      InfoRow(title: Text('Оплата'), trailing: Text(vm.deliveryPoint.paymentTypeName ?? '')),
      InfoRow(title: Text('Заказы')),
    ]..addAll(vm.deliveryOrders.map<Widget>((e) => _buildOrderTile(context, e, vm.deliveryPoint)).toList());
  }

  List<Widget> _buildPickupTiles(BuildContext context) {
    DeliveryPointViewModel vm = Provider.of<DeliveryPointViewModel>(context);

    return [
      InfoRow(title: Text('ИМ'), trailing: Text(vm.deliveryPoint.pickupSellerName ?? '')),
      InfoRow(title: Text('Отправитель'), trailing: Text(vm.deliveryPoint.senderName ?? '')),
      InfoRow(
        title: Text('Телефон'),
        trailing: GestureDetector(
          onTap: vm.callPhone,
          child: Text(vm.deliveryPoint.senderPhone ?? '', style: TextStyle(color: Colors.blue))
        )
      ),
      InfoRow(title: Text('Заказы')),
    ]..addAll(vm.pickupOrders.map<Widget>((e) => _buildOrderTile(context, e, vm.deliveryPoint)).toList());
  }

  Widget _buildOrderTile(BuildContext context, Order order, DeliveryPoint deliveryPoint) {
    return ListTile(
      title: Text('Заказ ${order.trackingNumber}', style: TextStyle(fontSize: 14)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ChangeNotifierProvider<OrderViewModel>(
              create: (context) => OrderViewModel(
                context: context,
                order: order,
                deliveryPoint: deliveryPoint
              ),
              child: OrderPage(),
            )
          )
        );
      },
    );
  }
}
