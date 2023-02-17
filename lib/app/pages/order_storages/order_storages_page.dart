import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery, Value;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '/app/constants/strings.dart';
import '/app/entities/entities.dart';
import '/app/data/database.dart';
import '/app/pages/order_storage/order_storage_page.dart';
import '/app/pages/order_qr_scan/order_qr_scan_page.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/services/api.dart';
import '/app/widgets/widgets.dart';

part 'order_storages_state.dart';
part 'order_storages_view_model.dart';

class OrderStoragesPage extends StatelessWidget {
  OrderStoragesPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderStoragesViewModel>(
      create: (context) => OrderStoragesViewModel(context),
      child: _OrderStoragesView(),
    );
  }
}

class _OrderStoragesView extends StatefulWidget {
  @override
  _OrderStoragesViewState createState() => _OrderStoragesViewState();
}

class _OrderStoragesViewState extends State<_OrderStoragesView> {
  late final ProgressDialog _progressDialog = ProgressDialog(context: context);

  Future<void> showQRPage() async {
    OrderStoragesViewModel vm = context.read<OrderStoragesViewModel>();

    Order? order = await Navigator.push(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (BuildContext context) => OrderQRScanPage())
    );

    if (order != null) await vm.takeNewOrder(order);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderStoragesViewModel, OrderStoragesState>(
        builder: (context, state) {
          OrderStoragesViewModel vm = context.read<OrderStoragesViewModel>();

          return Scaffold(
            appBar: AppBar(
              title: const Text(Strings.orderStoragesPageName)
            ),
            persistentFooterButtons: [
              TextButton(
                onPressed: vm.startQRScan,
                child: Column(children: const [Icon(Icons.fact_check, color: Colors.black), Text('Приемка')]),
                style: TextButton.styleFrom(foregroundColor: Colors.blue)
              )
            ],
            body: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
              children: state.orderStorages.map((e) => _orderStorageTile(context, e)).toList()
            )
          );
        },
        listener: (context, state) async {
          switch (state.status) {
            case OrderStoragesStateStatus.inProgress:
              await _progressDialog.open();
              break;
            case OrderStoragesStateStatus.startedQRScan:
              await showQRPage();
              break;
            case OrderStoragesStateStatus.accepted:
            case OrderStoragesStateStatus.failure:
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
              _progressDialog.close();
              break;
            default:
          }
        }
    );
  }

  Widget _orderStorageTile(BuildContext context, OrderStorage orderStorage) {
    return ListTile(
      title: Text(orderStorage.name, style: const TextStyle(fontSize: 14.0)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OrderStoragePage(orderStorage: orderStorage)
          )
        );
      }
    );
  }
}
