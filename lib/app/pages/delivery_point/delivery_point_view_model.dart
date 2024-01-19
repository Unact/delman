part of 'delivery_point_page.dart';

class DeliveryPointViewModel extends PageViewModel<DeliveryPointState, DeliveryPointStateStatus> {
  final DeliveriesRepository deliveriesRepository;

  StreamSubscription<List<DeliveryPointExResult>>? deliveryPointExListSubscription;
  StreamSubscription<List<DeliveryPointOrderExResult>>? deliveryPointOrderExListSubscription;

  DeliveryPointViewModel(
    this.deliveriesRepository,
    {
      required DeliveryPointExResult deliveryPointEx
    }
  ) : super(DeliveryPointState(deliveryPointEx: deliveryPointEx));

  @override
  DeliveryPointStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    deliveryPointExListSubscription = deliveriesRepository.watchExDeliveryPoints().listen((event) {
      emit(state.copyWith(
        status: DeliveryPointStateStatus.dataLoaded,
        deliveryPointEx: event.firstWhereOrNull((el) => el.dp.id == state.deliveryPointEx.dp.id)
      ));
    });
    deliveryPointOrderExListSubscription = deliveriesRepository.watchExDeliveryPointOrders().listen((event) {
      emit(state.copyWith(
        status: DeliveryPointStateStatus.dataLoaded,
        deliveryPointOrdersEx: event.where((el) => el.dpo.deliveryPointId == state.deliveryPointEx.dp.id).toList()
      ));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await deliveryPointExListSubscription?.cancel();
    await deliveryPointOrderExListSubscription?.cancel();
  }

  Future<void> callPhone() async {
    await Misc.callPhone(state.deliveryPointEx.dp.phone, onError: () {
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
      await deliveriesRepository.arriveAtDeliveryPoint(
        deliveryPointEx: state.deliveryPointEx,
        position: await Geolocator.getCurrentPosition(),
        factArrival: DateTime.now()
      );

      emit(state.copyWith(status: DeliveryPointStateStatus.arrivalSaved, message: 'Прибытие успешно отмечено'));
    } on AppError catch(e) {
      emit(state.copyWith(status: DeliveryPointStateStatus.failure, message: e.message));
    }
  }
}
