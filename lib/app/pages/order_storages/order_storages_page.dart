import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/order_storage/order_storage_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'order_storages_state.dart';
part 'order_storages_view_model.dart';

class OrderStoragesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderStoragesViewModel>(
      create: (context) => OrderStoragesViewModel(context),
      child: OrderStoragesView(),
    );
  }
}

class OrderStoragesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Strings.orderStoragesPageName)
      ),
      body: BlocBuilder<OrderStoragesViewModel, OrderStoragesState>(
        builder: (context, state) {
          OrderStoragesViewModel vm = context.read<OrderStoragesViewModel>();

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
            builder: (BuildContext context) => OrderStoragePage(orderStorage: orderStorage)
          )
        );
      }
    );
  }
}
