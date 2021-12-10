part of 'point_address_page.dart';

class PointAddressViewModel extends PageViewModel<PointAddressState> {
  DeliveryPoint deliveryPoint;

  PointAddressViewModel(BuildContext context, {required this.deliveryPoint}) : super(context, PointAddressInitial());

  List<DeliveryPoint> get deliveryPoints => appViewModel.deliveryPoints..sort((a, b) => a.seq.compareTo(b.seq));

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

    emit(PointAddressSelectionChange());
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
      emit(PointAddressFailure(Strings.genericErrorMsg));
    }
  }

  List<DeliveryPointOrder> _getDeliveryPointOrders(DeliveryPoint deliveryPoint) {
    return appViewModel.deliveryPointOrders.where(
      (e) => e.deliveryPointId == deliveryPoint.id
    ).toList();
  }

  Order _getOrder(DeliveryPointOrder deliveryPointOrder) {
    return appViewModel.orders.firstWhere((e) => e.id == deliveryPointOrder.orderId);
  }
}
