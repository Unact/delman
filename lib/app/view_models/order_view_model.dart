import 'package:flutter/material.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/view_models/base_view_model.dart';


class OrderViewModel extends BaseViewModel {
  Order order;
  late List<OrderInfo> orderInfoList = [];
  late List<OrderLine> orderLines = [];

  OrderViewModel({required BuildContext context, required this.order}) : super(context: context) {
    orderInfoList = appState.orderInfoList.where((e) => e.orderId == order.id).toList();
    orderLines = appState.orderLines.where((e) => e.orderId == order.id).toList();
  }

  List<OrderInfo> get sortedOrderInfoList => orderInfoList..sort((a, b) => b.ts.compareTo(a.ts));
  List<OrderLine> get sortedOrderLines => orderLines..sort((a, b) => a.name.compareTo(b.name));
  bool get withCourier => order.storageId == appState.user.storageId;
}
