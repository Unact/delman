import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/delivery_point_page.dart';
import 'package:delman/app/pages/order_page.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/delivery_point_view_model.dart';
import 'package:delman/app/view_models/delivery_view_model.dart';
import 'package:delman/app/view_models/order_view_model.dart';

class DeliveryPage extends StatelessWidget {
  const DeliveryPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.deliveryPageName)
      ),
      body: Consumer<DeliveryViewModel>(
        builder: (context, vm, _) {
          return ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
            children: vm.deliveryPoints.map((e) => _deliveryPointTile(context, e)).toList()
          );
        }
      )
    );
  }

  Widget _deliveryPointTile(BuildContext context, DeliveryPoint deliveryPoint) {
    DeliveryViewModel vm = Provider.of<DeliveryViewModel>(context);
    Color color = deliveryPoint.isFinished ?
      Colors.green[400] :
      (deliveryPoint.inProgress ? Colors.yellow[400] : Colors.blue[400]);

    return ExpansionTile(
      initiallyExpanded: false,
      tilePadding: EdgeInsets.all(0),
      leading: GestureDetector(
        child: CircleAvatar(
          child: Text(deliveryPoint.seq.toString(), style: TextStyle(color: Colors.black)),
          backgroundColor: color,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ChangeNotifierProvider<DeliveryPointViewModel>(
                create: (context) => DeliveryPointViewModel(context: context, deliveryPoint: deliveryPoint),
                child: DeliveryPointPage(),
              )
            )
          );
        }
      ),
      title: Text(deliveryPoint.addressName, style: TextStyle(fontSize: 14.0)),
      subtitle: RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
              text: '${Strings.planArrival}: ${Format.timeStr(deliveryPoint.planArrival)}\n',
              style: TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
            TextSpan(
              text: '${Strings.factArrival}: ${Format.timeStr(deliveryPoint.factArrival)}\n',
              style: TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
            TextSpan(
              text: '${Strings.factDeparture}: ${Format.timeStr(deliveryPoint.factDeparture)}\n',
              style: TextStyle(color: Colors.grey, fontSize: 12.0)
            ),
          ]
        ),
      ),
      children: [
        Divider(height: 1, indent: 20),
        ...vm.getOrdersForDeliveryPoint(deliveryPoint).map((Order order) {
          return ListTile(
            title: Text('Заказ ${order.trackingNumber}'),
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ChangeNotifierProvider<OrderViewModel>(
                    create: (context) => OrderViewModel(
                      context: context,
                      order: order
                    ),
                    child: OrderPage(),
                  )
                )
              );
            },
          );
        }).toList()
      ]
    );
  }
}
