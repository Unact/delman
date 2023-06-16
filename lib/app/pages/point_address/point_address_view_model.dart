part of 'point_address_page.dart';

class PointAddressViewModel extends PageViewModel<PointAddressState, PointAddressStateStatus> {
  PointAddressViewModel(
    BuildContext context,
    {
      required DeliveryPointExResult deliveryPointEx
    }
  ) : super(context, PointAddressState(deliveryPointEx: deliveryPointEx));

  @override
  PointAddressStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.deliveryPointOrders,
    app.storage.deliveryPoints,
  ]);

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: PointAddressStateStatus.dataLoaded,
      deliveryPointEx: await app.storage.deliveriesDao.getExDeliveryPoint(state.deliveryPointEx.dp.id),
      allPoints: (await app.storage.deliveriesDao.getExDeliveryPoints(state.deliveryPointEx.dp.deliveryId))
    ));
  }

  Future<void> changeDeliveryPoint(DeliveryPointExResult newDeliveryPointEx) async {
    emit(state.copyWith(
      status: PointAddressStateStatus.selectionChange,
      deliveryPointEx: await app.storage.deliveriesDao.getExDeliveryPoint(newDeliveryPointEx.dp.id),
    ));
  }

  void routeTo() async {
    Location? location = await GeoLoc.getCurrentLocation();
    String params = 'rtext='
      '${location?.latitude},${location?.longitude}'
      '~'
      '${state.deliveryPointEx.dp.latitude},${state.deliveryPointEx.dp.longitude}';
    Uri uri = Uri.parse('yandexmaps://maps.yandex.ru?$params');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      emit(state.copyWith(status: PointAddressStateStatus.failure, message: Strings.genericErrorMsg));
    }
  }
}
