import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum DeliveryPointState {
  Initial,
  InProgress,
  ArrivalSaved,
  Failure
}

class DeliveryPointViewModel extends BaseViewModel {
  DeliveryPoint deliveryPoint;
  DeliveryPointState _state = DeliveryPointState.Initial;

  String? _message;

  DeliveryPointViewModel({required BuildContext context, required this.deliveryPoint}) : super(context: context);

  DeliveryPointState get state => _state;
  String? get message => _message;

  List<Order> get deliveryOrders {
    return appState.orders
      .where((e) => e.deliveryPointId == deliveryPoint.id && !e.isPickup)
      .toList()
      ..sort((a, b) => a.trackingNumber.compareTo(b.trackingNumber));
  }
  List<Order> get pickupOrders {
    return appState.orders
      .where((e) => e.deliveryPointId == deliveryPoint.id && e.isPickup)
      .toList()
      ..sort((a, b) => a.trackingNumber.compareTo(b.trackingNumber));
  }

  Future<void> callPhone() async {
    await Misc.callPhone(deliveryPoint.phone, onFailure: () {
      _setMessage(Strings.genericErrorMsg);
      _setState(DeliveryPointState.Failure);
    });
  }

  Future<void> arrive() async {
    _setState(DeliveryPointState.InProgress);

    try {
      deliveryPoint = await appState.arriveAtDeliveryPoint(deliveryPoint);

      _setMessage('Прибытие успешно отмечено');
      _setState(DeliveryPointState.ArrivalSaved);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(DeliveryPointState.Failure);
    }
  }

  void _setState(DeliveryPointState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
