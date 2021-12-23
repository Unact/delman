import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/app/app_page.dart';
import 'package:delman/app/pages/order/order_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';
import 'package:delman/app/pages/order_qr_scan/order_qr_scan_page.dart';

part 'order_storage_state.dart';
part 'order_storage_view_model.dart';

class OrderStoragePage extends StatelessWidget {
  final OrderStorage orderStorage;

  OrderStoragePage({
    Key? key,
    required this.orderStorage
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderStorageViewModel>(
      create: (context) => OrderStorageViewModel(context, orderStorage: orderStorage),
      child: _OrderStorageView(),
    );
  }
}

class _OrderStorageView extends StatefulWidget {
  @override
  _OrderStorageViewState createState() => _OrderStorageViewState();
}

class _OrderStorageViewState extends State<_OrderStorageView> {
  Completer<void> _dialogCompleter = Completer();

  Future<void> openDialog() async {
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
          title: const Text('Предупреждение'),
          content: SingleChildScrollView(child: ListBody(children: <Widget>[Text(message)])),
          actions: <Widget>[
            TextButton(child: const Text(Strings.ok), onPressed: () => Navigator.of(context).pop(true)),
            TextButton(child: const Text(Strings.cancel), onPressed: () => Navigator.of(context).pop(false))
          ],
        );
      }
    ) ?? false;
  }

  Future<void> showQRPage() async {
    OrderStorageViewModel vm = context.read<OrderStorageViewModel>();

     Order? order = await Navigator.push(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) => OrderQRScanPage())
    );

    if (order != null) await vm.tryMoveOrder(order);
  }

  Future<void> showManualInput() async {
    OrderStorageViewModel vm = context.read<OrderStorageViewModel>();
    TextEditingController trackingNumberController = TextEditingController();
    TextEditingController packagesController = TextEditingController();

    Order? order = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                enableInteractiveSelection: false,
                textCapitalization: TextCapitalization.words,
                controller: trackingNumberController,
                decoration: const InputDecoration(labelText: 'Трекинг'),
              ),
              TextField(
                enableInteractiveSelection: false,
                textCapitalization: TextCapitalization.words,
                controller: packagesController,
                decoration: const InputDecoration(labelText: 'Кол-во мест'),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Order? order = vm.orderFromManualInput(trackingNumberController.text, packagesController.text);

                Navigator.of(context).pop(order);
              },
              child: const Text('Подтвердить')
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Отменить')
            )
          ]
        );
      }
    );

    if (order != null) await vm.tryMoveOrder(order);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderStorageViewModel, OrderStorageState>(
      builder: (context, vm) {
        OrderStorageViewModel vm = context.read<OrderStorageViewModel>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Заказы на складе'),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.qr_code),
                onPressed: vm.startQRScan,
                tooltip: 'Сканировать QR код'
              ),
              IconButton(
                icon: const Icon(Icons.text_fields),
                onPressed: showManualInput,
                tooltip: 'Указать вручную',
              ),
            ]
          ),
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
            children: [
              ExpansionTile(
                title: Text(vm.orderStorage.name),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                children: vm.ordersInOrderStorage.map((e) => _buildOrderNotInOwnStorageTile(context, e)).toList()
              ),
              ExpansionTile(
                title: const Text('Принятые'),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 8),
                children: vm.ordersInOwnStorage.map((e) => _buildOrderInOwnStorageTile(context, e)).toList()
              )
            ]
          )
        );
      },
      listener: (context, state) async {
        if (state is OrderStorageInProgress) {
          openDialog();
        } else if (state is OrderStorageStartedQRScan) {
          await showQRPage();
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
      }
    );
  }

  Widget _buildOrderInOwnStorageTile(BuildContext context, Order order) {
    return ListTile(
      title: Text('Заказ ${order.trackingNumber}', style: const TextStyle(fontSize: 14)),
      subtitle: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.grey),
          children: <TextSpan>[
            TextSpan(text: 'Номер ИМ: ${order.number}\n', style: const TextStyle(fontSize: 12.0)),
            TextSpan(text: 'Адрес доставки: ${order.deliveryAddressName}\n', style: const TextStyle(fontSize: 12.0)),
            TextSpan(text: 'Адрес забора: ${order.pickupAddressName}\n', style: const TextStyle(fontSize: 12.0))
          ]
        )
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
    return ListTile(
      title: Text('Заказ ${order.trackingNumber}', style: const TextStyle(fontSize: 14)),
      subtitle: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.grey),
          children: <TextSpan>[
            TextSpan(text: 'Номер ИМ: ${order.number}\n', style: const TextStyle(fontSize: 12.0)),
            TextSpan(text: 'Адрес доставки: ${order.deliveryAddressName}\n', style: const TextStyle(fontSize: 12.0)),
            TextSpan(text: 'Адрес забора: ${order.pickupAddressName}\n', style: const TextStyle(fontSize: 12.0))
          ]
        )
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
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
