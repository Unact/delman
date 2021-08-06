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
  Failure,
  NeedUserConfirmation
}

class OrderStorageViewModel extends BaseViewModel {
  OrderStorage orderStorage;
  Function? _confirmationCallback;
  String? _message;
  OrderStorageState _state = OrderStorageState.Initial;

  OrderStorageViewModel({
    required BuildContext context,
    required this.orderStorage,
  }) : super(context: context);

  OrderStorageState get state => _state;
  String? get message => _message;
  Function? get confirmationCallback => _confirmationCallback;

  List<Order> get ordersInOwnStorage {
    return appState.orders
      .where((e) => e.storageId == appState.user.storageId).toList()
      ..sort((a, b) => a.trackingNumber.compareTo(b.trackingNumber));
  }

  List<Order> get ordersInOrderStorage {
    return appState.orders
      .where((e) => e.storageId == orderStorage.id)
      .toList()
      ..sort((a, b) => a.trackingNumber.compareTo(b.trackingNumber));
  }

  Future<void> tryAcceptOrder(Order order) async {
    if (order.needDocumentsReturn) {
      _confirmationCallback = (bool confirmed) async {
        if (!confirmed) {
          _setMessage('Нельзя принять заказ без возврата документов');
          _setState(OrderStorageState.Failure);
          return;
        }

        await acceptOrder(order);
      };
      _setMessage('Вы забрали документы?');
      _setState(OrderStorageState.NeedUserConfirmation);

      return;
    }

    await acceptOrder(order);
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

  Future<void> transferOrder(Order order) async {
    _setState(OrderStorageState.InProgress);

    try {
      await appState.transferOrder(order, orderStorage);
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
