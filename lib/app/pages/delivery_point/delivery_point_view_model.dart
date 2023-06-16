part of 'delivery_point_page.dart';

class DeliveryPointViewModel extends PageViewModel<DeliveryPointState, DeliveryPointStateStatus> {
  DeliveryPointViewModel(
    BuildContext context,
    {
      required DeliveryPointExResult deliveryPointEx
    }
  ) : super(context, DeliveryPointState(deliveryPointEx: deliveryPointEx));

  @override
  DeliveryPointStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.deliveryPoints,
    app.storage.deliveryPointOrders,
    app.storage.orders,
  ]);

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: DeliveryPointStateStatus.dataLoaded,
      deliveryPointEx: await app.storage.deliveriesDao.getExDeliveryPoint(state.deliveryPointEx.dp.id),
      deliveryPointOrdersEx: await app.storage.deliveriesDao.getExDeliveryPointOrders(state.deliveryPointEx.dp.id)
    ));
  }

  Future<void> callPhone() async {
    await Misc.callPhone(state.deliveryPointEx.dp.phone, onFailure: () {
      emit(state.copyWith(status: DeliveryPointStateStatus.failure, message: Strings.genericErrorMsg));
    });
  }

  Future<void> copyOrderInfo(Order order) async {
    String text = 'ИМ: ${order.sellerName}\n'
      'Номер в ИМ: ${order.number}\n'
      'Трекинг: ${order.trackingNumber}\n'
      'Адрес: ${state.deliveryPointEx.dp.addressName}';
    await Clipboard.setData(ClipboardData(text: text));

    emit(state.copyWith(status: DeliveryPointStateStatus.orderDataCopied, message: 'Данные о заказе скопированы'));
  }

  Future<void> arrive() async {
    emit(state.copyWith(status: DeliveryPointStateStatus.inProgress));

    try {
      await _arriveAtDeliveryPoint();

      emit(state.copyWith(status: DeliveryPointStateStatus.arrivalSaved, message: 'Прибытие успешно отмечено'));
    } on AppError catch(e) {
      emit(state.copyWith(status: DeliveryPointStateStatus.failure, message: e.message));
    }
  }

  Future<void> _arriveAtDeliveryPoint() async {
    Location? location = await GeoLoc.getCurrentLocation();
    DateTime factArrival = DateTime.now();

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    try {
      await app.api.arriveAtDeliveryPoint(
        deliveryPointId: state.deliveryPointEx.dp.id,
        factArrival: factArrival,
        location: location
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.storage.deliveriesDao.updateDeliveryPoint(
      state.deliveryPointEx.dp.id,
      DeliveryPointsCompanion(factArrival: Value(factArrival))
    );
  }
}
