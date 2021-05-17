import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/order_page.dart';
import 'package:delman/app/view_models/order_view_model.dart';
import 'package:delman/app/view_models/order_storage_view_model.dart';

class OrderStoragePage extends StatefulWidget {
  const OrderStoragePage({Key key}) : super(key: key);

  @override
  _OrderStoragePageState createState() => _OrderStoragePageState();
}

class _OrderStoragePageState extends State<OrderStoragePage> {
  OrderStorageViewModel _orderStorageViewModel;
  Completer<void> _dialogCompleter = Completer();

  @override
  void initState() {
    super.initState();

    _orderStorageViewModel = context.read<OrderStorageViewModel>();
    _orderStorageViewModel.addListener(this.vmListener);
  }

  @override
  void dispose() {
    _orderStorageViewModel.removeListener(this.vmListener);
    super.dispose();
  }

  Future<void> openDialog() async {
    showDialog(
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator()),
      barrierDismissible: false
    );
    await _dialogCompleter.future;
    Navigator.of(context).pop();
  }

  void closeDialog() {
    _dialogCompleter.complete();
    _dialogCompleter = Completer();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> vmListener() async {
    switch (_orderStorageViewModel.state) {
      case OrderStorageState.InProgress:
        openDialog();
        break;
      case OrderStorageState.Failure:
      case OrderStorageState.Accepted:
      case OrderStorageState.Transferred:
        showMessage(_orderStorageViewModel.message);
        closeDialog();
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderStorageViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Заказы на складе')
          ),
          body: ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
            children: [
              ExpansionTile(
                title: Text(vm.orderStorage.name),
                initiallyExpanded: true,
                tilePadding: EdgeInsets.symmetric(horizontal: 8),
                children: vm.ordersInOrderStorage.map((e) => _buildOrderNotInOwnStorageTile(context, e)).toList()
              ),
              ExpansionTile(
                title: Text('Принятые'),
                initiallyExpanded: true,
                tilePadding: EdgeInsets.symmetric(horizontal: 8),
                children: vm.ordersInOwnStorage.map((e) => _buildOrderInOwnStorageTile(context, e)).toList()
              )
            ]
          )
        );
    });
  }

  Widget _buildOrderInOwnStorageTile(BuildContext context, Order order) {
    OrderStorageViewModel vm = Provider.of<OrderStorageViewModel>(context);

    return ListTile(
      title: Text('Заказ ${order.trackingNumber}', style: TextStyle(fontSize: 14)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          primary: Colors.blue,
        ),
        child: Text('Передать'),
        onPressed: () => vm.transferOrder(order)
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ChangeNotifierProvider<OrderViewModel>(
              create: (context) => OrderViewModel(
                context: context,
                order: order,
                deliveryPoint: vm.getDeliveryPointForOrder(order)
              ),
              child: OrderPage(),
            )
          )
        );
      },
    );
  }

  Widget _buildOrderNotInOwnStorageTile(BuildContext context, Order order) {
    OrderStorageViewModel vm = Provider.of<OrderStorageViewModel>(context);

    return ListTile(
      title: Text('Заказ ${order.trackingNumber}', style: TextStyle(fontSize: 14)),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          primary: Colors.blue,
        ),
        child: Text('Принять'),
        onPressed: () => vm.acceptOrder(order)
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ChangeNotifierProvider<OrderViewModel>(
              create: (context) => OrderViewModel(
                context: context,
                order: order,
                deliveryPoint: vm.getDeliveryPointForOrder(order)
              ),
              child: OrderPage(),
            )
          )
        );
      },
    );
  }
}
