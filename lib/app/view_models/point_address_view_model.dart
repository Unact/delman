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
}
