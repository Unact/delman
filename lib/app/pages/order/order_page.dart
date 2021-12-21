
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';
import 'package:delman/app/widgets/widgets.dart';

part 'order_state.dart';
part 'order_view_model.dart';

class OrderPage extends StatelessWidget {
  final Order order;

  OrderPage({
    Key? key,
    required this.order
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderViewModel>(
      create: (context) => OrderViewModel(context, order: order),
      child: _OrderView(),
    );
  }
}

class _OrderView extends StatefulWidget {
  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends State<_OrderView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderViewModel, OrderState>(
      builder: (context, state) {
        OrderViewModel vm = context.read<OrderViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: Text('Заказ ${vm.order.trackingNumber}'),
            centerTitle: true
          ),
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            children: [
              InfoRow(
                title: const Text('Посылка'),
                trailing: Text(vm.withCourier ? 'На борту' : 'Не на борту')
              ),
              InfoRow(
                title: const Text('Возврат документов'),
                trailing: Text(vm.order.needDocumentsReturn ? 'Да' : 'Нет')
              ),
              InfoRow(title: const Text('ИМ'), trailing: Text(vm.order.sellerName)),
              InfoRow(title: const Text('Номер в ИМ'), trailing: Text(vm.order.number)),
              InfoRow(
                title: const Text('Отправитель'),
                trailing: Text(vm.order.senderName ?? '')
              ),
              InfoRow(
                title: const Text('Покупатель'),
                trailing: Text(vm.order.buyerName ?? '')
              ),
              InfoRow(
                title: const Text('Адрес забора'),
                trailing: Text(vm.order.pickupAddressName)
              ),
              InfoRow(
                title: const Text('Адрес доставки'),
                trailing: Text(vm.order.deliveryAddressName)
              ),
              InfoRow(title: const Text('Примечание'), trailing: ExpandingText(vm.order.comment ?? '')),
              ExpansionTile(
                title: const Text('Позиции'),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                children: vm.sortedOrderLines.map<Widget>((e) => _buildOrderLineTile(context, e)).toList()
              ),
              ExpansionTile(
                title: const Text('Служебная информация'),
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SizedBox(
              height: 20,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExpandingText(orderInfo.comment,
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 12)
                ),
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
            child: SizedBox(
              height: 36,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ExpandingText(orderLine.name, textAlign: TextAlign.left, style: const TextStyle(fontSize: 12)),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
