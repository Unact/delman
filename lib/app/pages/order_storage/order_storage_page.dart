import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/order/order_page.dart';
import 'package:delman/app/pages/qr_scan_page.dart';
import 'package:delman/app/pages/app/app_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'order_storage_state.dart';
part 'order_storage_view_model.dart';

class OrderStoragePage extends StatelessWidget {
  final OrderStorage orderStorage;

  const OrderStoragePage({
    required this.orderStorage
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderStorageViewModel>(
      create: (context) => OrderStorageViewModel(context, orderStorage: orderStorage),
      child: OrderStorageView(),
    );
  }
}

class OrderStorageView extends StatefulWidget {
  @override
  _OrderStorageViewState createState() => _OrderStorageViewState();
}

class _OrderStorageViewState extends State<OrderStorageView> {
  Completer<void> _dialogCompleter = Completer();

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

  Future<bool> showConfirmationDialog(String message) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Предупреждение'),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Text(message)])),
          actions: <Widget>[
            TextButton(child: Text(Strings.ok), onPressed: () => Navigator.of(context).pop(true)),
            TextButton(child: Text(Strings.cancel), onPressed: () => Navigator.of(context).pop(false))
          ],
        );
      }
    ) ?? false;
  }

  Future<String?> showQRScanPage() async {
    return await Navigator.push(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) => QRScanPage())
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderStorageViewModel, OrderStorageState>(
      builder: (context, vm) {
        OrderStorageViewModel vm = context.read<OrderStorageViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: Text('Заказы на складе'),
            actions: <Widget>[
              IconButton(
                color: Colors.white,
                icon: Icon(Icons.qr_code_scanner),
                onPressed: vm.startQRScan
              )
            ]
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
    },
    listener: (context, state) async {
      OrderStorageViewModel vm = context.read<OrderStorageViewModel>();

      if (state is OrderStorageInProgress) {
        openDialog();
      } else if (state is OrderStorageStartedQRScan) {
        vm.finishQRScan(await showQRScanPage());
      } else if (state is OrderStorageNeedUserConfirmation) {
        state.confirmationCallback(await showConfirmationDialog(state.message));
      } else if (state is OrderStorageFailure) {
        showMessage(state.message);
        closeDialog();
      } else if (state is OrderStorageAccepted) {
        showMessage(state.message);
        closeDialog();
      } else if (state is OrderStorageTransferred) {
        showMessage(state.message);
        closeDialog();
      }
    });
  }

  Widget _buildOrderInOwnStorageTile(BuildContext context, Order order) {
    OrderStorageViewModel vm = context.read<OrderStorageViewModel>();

    return ListTile(
      title: Text('Заказ ${order.trackingNumber}', style: TextStyle(fontSize: 14)),
      subtitle: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.grey),
          children: <TextSpan>[
            TextSpan(text: 'Номер ИМ: ${order.number}\n', style: TextStyle(fontSize: 12.0)),
            TextSpan(text: 'Адрес доставки: ${order.deliveryAddressName}\n', style: TextStyle(fontSize: 12.0)),
            TextSpan(text: 'Адрес забора: ${order.pickupAddressName}\n', style: TextStyle(fontSize: 12.0))
          ]
        )
      ),
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
            builder: (BuildContext context) => OrderPage(order: order)
          )
        );
      },
    );
  }

  Widget _buildOrderNotInOwnStorageTile(BuildContext context, Order order) {
    OrderStorageViewModel vm = context.read<OrderStorageViewModel>();

    return ListTile(
      title: Text('Заказ ${order.trackingNumber}', style: TextStyle(fontSize: 14)),
      subtitle: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.grey),
          children: <TextSpan>[
            TextSpan(text: 'Номер ИМ: ${order.number}\n', style: TextStyle(fontSize: 12.0)),
            TextSpan(text: 'Адрес доставки: ${order.deliveryAddressName}\n', style: TextStyle(fontSize: 12.0)),
            TextSpan(text: 'Адрес забора: ${order.pickupAddressName}\n', style: TextStyle(fontSize: 12.0))
          ]
        )
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          primary: Colors.blue,
        ),
        child: Text('Принять'),
        onPressed: () => vm.tryAcceptOrder(order)
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OrderPage(order: order)
          )
        );
      },
    );
  }
}