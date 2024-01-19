import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/constants/strings.dart';
import '/app/entities/entities.dart';
import '/app/data/database.dart';
import '/app/pages/order_storage/order_storage_page.dart';
import '/app/pages/order_qr_scan/order_qr_scan_page.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/repositories/order_storages_repository.dart';
import '/app/repositories/orders_repository.dart';
import '/app/repositories/users_repository.dart';

part 'order_storages_state.dart';
part 'order_storages_view_model.dart';

class OrderStoragesPage extends StatelessWidget {
  OrderStoragesPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderStoragesViewModel>(
      create: (context) => OrderStoragesViewModel(
        RepositoryProvider.of<OrderStoragesRepository>(context),
        RepositoryProvider.of<OrdersRepository>(context),
        RepositoryProvider.of<UsersRepository>(context)
      ),
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

  @override
  void dispose() {
    _progressDialog.close();
    super.dispose();
  }

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
                style: TextButton.styleFrom(foregroundColor: Colors.blue),
                child: const Column(children: [Icon(Icons.fact_check, color: Colors.black), Text('Приемка')])
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
              Misc.showMessage(context, state.message);
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
