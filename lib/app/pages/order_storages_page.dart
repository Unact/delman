import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/order_storage_page.dart';
import 'package:delman/app/view_models/order_storage_view_model.dart';
import 'package:delman/app/view_models/order_storages_view_model.dart';

class OrderStoragesPage extends StatelessWidget {
  const OrderStoragesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.orderStoragesPageName)
      ),
      body: Consumer<OrderStoragesViewModel>(
        builder: (context, vm, _) {
          return ListView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(top: 24, left: 8, right: 8, bottom: 24),
            children: vm.orderStorages.map((e) => _orderStorageTile(context, e)).toList()
          );
        }
      )
    );
  }

  Widget _orderStorageTile(BuildContext context, OrderStorage orderStorage) {
    return ListTile(
      title: Text(orderStorage.name, style: TextStyle(fontSize: 14.0)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => ChangeNotifierProvider<OrderStorageViewModel>(
              create: (context) => OrderStorageViewModel(
                context: context,
                orderStorage: orderStorage,
              ),
              child: OrderStoragePage(),
            )
          )
        );
      }
    );
  }
}
