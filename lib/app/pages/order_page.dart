
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/order_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<OrderViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ ${vm.order.trackingNumber}'),
            centerTitle: true
          ),
          body: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 24, bottom: 24),
            children: [
              InfoRow(
                title: Text('Посылка'),
                trailing: Text(vm.withCourier ? 'На борту' : 'Не на борту')
              ),
              InfoRow(
                title: Text('Возврат документов'),
                trailing: Text(vm.order.needDocumentsReturn ? 'Да' : 'Нет')
              ),
              InfoRow(title: Text('ИМ'), trailing: Text(vm.order.sellerName)),
              InfoRow(title: Text('Номер в ИМ'), trailing: Text(vm.order.number)),
              InfoRow(
                title: Text('Отправитель'),
                trailing: Text(vm.order.senderName ?? '')
              ),
              InfoRow(
                title: Text('Покупатель'),
                trailing: Text(vm.order.buyerName ?? '')
              ),
              InfoRow(
                title: Text('Адрес забора'),
                trailing: Text(vm.order.pickupAddressName)
              ),
              InfoRow(
                title: Text('Адрес доставки'),
                trailing: Text(vm.order.deliveryAddressName)
              ),
              InfoRow(title: Text('Примечание'), trailing: ExpandingText(vm.order.comment ?? '')),
              ExpansionTile(
                title: Text('Позиции'),
                initiallyExpanded: true,
                tilePadding: EdgeInsets.symmetric(horizontal: 8),
                children: vm.sortedOrderLines.map<Widget>((e) => _buildOrderLineTile(context, e)).toList()
              ),
              ExpansionTile(
                title: Text('Служебная информация'),
                initiallyExpanded: false,
                tilePadding: EdgeInsets.symmetric(horizontal: 8),
                children: vm.sortedOrderInfoList.map<Widget>((e) => _buildOrderInfoTile(context, e)).toList()
              ),
            ],
          )
        );
      }
    );
  }

  Widget _buildOrderInfoTile(BuildContext context, OrderInfo orderInfo) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExpandingText(orderInfo.comment, textAlign: TextAlign.left, style: TextStyle(fontSize: 12)),
              )
            )
          ),
        ]
      ),
    );
  }

  Widget _buildOrderLineTile(BuildContext context, OrderLine orderLine) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Container(
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExpandingText(orderLine.name, textAlign: TextAlign.left, style: TextStyle(fontSize: 12)),
              )
            )
          ),
          Row(
            children: <Widget>[
              Text(Format.numberStr(orderLine.price) + ' x '),
              Text((orderLine.factAmount ?? orderLine.amount).toString())
            ],
          )
        ]
      ),
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
