import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum OrderStorageState {
  Initial,
  InProgress,
  Accepted,
  Transferred,
  Failure
}

class OrderStorageViewModel extends BaseViewModel {
  OrderStorage orderStorage;

  String? _message;
  OrderStorageState _state = OrderStorageState.Initial;

  OrderStorageViewModel({
    required BuildContext context,
    required this.orderStorage,
  }) : super(context: context);

  OrderStorageState get state => _state;
  String? get message => _message;

  List<UserStorageOrder> get ordersInOwnStorage {
    return appState.userStorageOrders..sort((a, b) => a.trackingNumber.compareTo(b.trackingNumber));
  }

  List<Order> get ordersInOrderStorage {
    return appState.orders
      .where((e) => e.orderStorageId == orderStorage.id)
      .toList()
      ..sort((a, b) => a.trackingNumber.compareTo(b.trackingNumber));
  }

  DeliveryPoint getDeliveryPointForOrder(Order order) {
    return appState.deliveryPoints.firstWhere((e) => e.id == order.deliveryPointId);
  }

  Future<void> acceptOrder(Order order) async {
    _setState(OrderStorageState.InProgress);

    try {
      await appState.acceptOrder(order);
      _setMessage('Заказ успешно принят');
      _setState(OrderStorageState.Accepted);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(OrderStorageState.Failure);
    }
  }

  Future<void> transferUserStorageOrder(UserStorageOrder userStorageOrder) async {
    _setState(OrderStorageState.InProgress);

    try {
      await appState.transferUserStorageOrder(userStorageOrder, orderStorage);
      _setMessage('Заказ успешно передан в ${orderStorage.name}');
      _setState(OrderStorageState.Transferred);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(OrderStorageState.Failure);
    }
  }

  void _setState(OrderStorageState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
