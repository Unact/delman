import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum OrderStorageState {
  Initial,
  InProgress,
  Accepted,
  Transferred,
  Failure,
  NeedUserConfirmation,
  StartedQRScan
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

  Future<void> startQRScan() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isPermanentlyDenied || status.isDenied) {
      _setMessage('Для сканирования QR кода необходимо разрешить использование камеры');
      _setState(OrderStorageState.Failure);
      return;
    }

    _setState(OrderStorageState.StartedQRScan);
  }

  Future<void> finishQRScan(String? qrCode) async {
    if (qrCode == null) return;

    List<String> qrCodeData = qrCode.split(' ');

    if (qrCodeData.length < 2 || qrCodeData[0] != Strings.qrCodeVersion) {
      _setMessage('Считан не поддерживаемый QR код');
      _setState(OrderStorageState.Failure);
      return;
    }

    String qrTrackingNumber = qrCodeData[1];

    if (ordersInOrderStorage.any((e) => e.trackingNumber == qrTrackingNumber)) {
      Order order = ordersInOrderStorage.firstWhere((e) => e.trackingNumber == qrTrackingNumber);
      await tryAcceptOrder(order);
      return;
    }

    if (ordersInOwnStorage.any((e) => e.trackingNumber == qrTrackingNumber)) {
      Order order = ordersInOwnStorage.firstWhere((e) => e.trackingNumber == qrTrackingNumber);
      await transferOrder(order);
      return;
    }

    _setMessage('Не удалось найти заказ');
    _setState(OrderStorageState.Failure);
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
