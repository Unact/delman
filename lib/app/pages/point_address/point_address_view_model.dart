part of 'point_address_page.dart';

class PointAddressViewModel extends PageViewModel<PointAddressState, PointAddressStateStatus> {
  final DeliveriesRepository deliveriesRepository;

  StreamSubscription<List<DeliveryPointExResult>>? deliveryPointExListSubscription;

  PointAddressViewModel(
    this.deliveriesRepository,
    {
      required DeliveryPointExResult deliveryPointEx
    }
  ) : super(PointAddressState(deliveryPointEx: deliveryPointEx));

  @override
  PointAddressStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    deliveryPointExListSubscription = deliveriesRepository.watchExDeliveryPoints().listen((event) {
      emit(state.copyWith(
        status: PointAddressStateStatus.dataLoaded,
        allPoints:  event.where((el) => el.dp.id != state.deliveryPointEx.dp.id).toList(),
        deliveryPointEx: event.firstWhereOrNull((el) => el.dp.id == state.deliveryPointEx.dp.id)
      ));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await deliveryPointExListSubscription?.cancel();
  }

  Future<void> changeDeliveryPoint(DeliveryPointExResult newDeliveryPointEx) async {
    emit(state.copyWith(
      status: PointAddressStateStatus.selectionChange,
      deliveryPointEx: newDeliveryPointEx
    ));
  }

  void routeTo() async {
    final position = await Geolocator.getCurrentPosition();
    String params = 'rtext='
      '${position.latitude},${position.longitude}'
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
