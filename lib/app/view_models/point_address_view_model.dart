import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/geo_loc.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum PointAddressState {
  Initial,
  SelectionChange,
  Failure
}

class PointAddressViewModel extends BaseViewModel {
  DeliveryPoint deliveryPoint;
  PointAddressState _state = PointAddressState.Initial;

  String? _message;

  PointAddressViewModel({required BuildContext context, required this.deliveryPoint}) : super(context: context);

  PointAddressState get state => _state;
  String? get message => _message;
  List<DeliveryPoint> get deliveryPoints => appState.deliveryPoints..sort((a, b) => a.seq.compareTo(b.seq));

  DateTime? getPointTimeTo(DeliveryPoint deliveryPoint) {
    List<DeliveryPointOrder> deliveryPointOrders = _getDeliveryPointOrders(deliveryPoint);

    return deliveryPointOrders.fold(null, (prevVal, deliveryPointOrder) {
      Order order = _getOrder(deliveryPointOrder);
      DateTime? timeTo = deliveryPointOrder.isPickup ? order.pickupDateTimeTo : order.deliveryDateTimeTo;
      DateTime? newVal = prevVal ?? timeTo;

      if (timeTo != null && newVal != null) {
        newVal = timeTo.isAfter(newVal) ? timeTo : newVal;
      }

      return newVal;
    });
  }

  DateTime? getPointTimeFrom(DeliveryPoint deliveryPoint) {
    List<DeliveryPointOrder> deliveryPointOrders = _getDeliveryPointOrders(deliveryPoint);

    return deliveryPointOrders.fold(null, (prevVal, deliveryPointOrder) {
      Order order = _getOrder(deliveryPointOrder);
      DateTime? timeFrom = deliveryPointOrder.isPickup ? order.pickupDateTimeFrom : order.deliveryDateTimeFrom;
      DateTime? newVal = prevVal ?? timeFrom;

      if (timeFrom != null && newVal != null) {
        newVal = timeFrom.isBefore(newVal) ? timeFrom : newVal;
      }

      return newVal;
    });
  }

  void changeDeliveryPoint(DeliveryPoint newDeliveryPoint) {
    deliveryPoint = newDeliveryPoint;

    _setState(PointAddressState.SelectionChange);
  }

  void routeTo() async {
    Location? location = await GeoLoc.getCurrentLocation();
    String params = 'rtext=' +
      '${location?.latitude},${location?.longitude}' +
      '~' +
      '${deliveryPoint.latitude},${deliveryPoint.longitude}';
    String url = 'yandexmaps://maps.yandex.ru?$params';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _setMessage(Strings.genericErrorMsg);
      _setState(PointAddressState.Failure);
    }
  }

  void _setState(PointAddressState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }

  List<DeliveryPointOrder> _getDeliveryPointOrders(DeliveryPoint deliveryPoint) {
    return appState.deliveryPointOrders.where(
      (e) => e.deliveryPointId == deliveryPoint.id
    ).toList();
  }

  Order _getOrder(DeliveryPointOrder deliveryPointOrder) {
    return appState.orders.firstWhere((e) => e.id == deliveryPointOrder.orderId);
  }
}
