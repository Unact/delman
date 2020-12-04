import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/geo_loc.dart';
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

  String _message;
  Placemark _placemark;

  DeliveryPointViewModel({@required BuildContext context, @required this.deliveryPoint}) : super(context: context) {
    _placemark = Placemark(
      point: Point(longitude: deliveryPoint.longitude, latitude: deliveryPoint.latitude),
      iconName: 'lib/app/assets/images/placeicon.png',
      onTap: (double lat, double lon) async {
        Location location = await GeoLoc.getCurrentLocation();
        String params = 'rtext=' +
          '${location.latitude},${location.longitude}' +
          '~' +
          '${deliveryPoint.latitude},${deliveryPoint.longitude}';
        String url = 'yandexmaps://maps.yandex.ru?$params';

        if (await canLaunch(url)) {
          await launch(url);
        } else {
          _setMessage(Strings.genericErrorMsg);
          _setState(DeliveryPointState.Failure);
        }
      }
    );
  }

  DeliveryPointState get state => _state;
  String get message => _message;

  Placemark get placemark => _placemark;

  List<Order> getOrders() {
    return appState.orders
      .where((e) => e.deliveryPointId == deliveryPoint.id)
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
      Location location = await GeoLoc.getCurrentLocation();
      deliveryPoint = await appState.arriveAtDeliveryPoint(deliveryPoint, location);

      _setMessage('Прибытие успешно отмечено');
      _setState(DeliveryPointState.ArrivalSaved);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(DeliveryPointState.Failure);
    }
  }

  void _setState(DeliveryPointState state) {
    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
