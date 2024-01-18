part of 'delivery_page.dart';

class DeliveryViewModel extends PageViewModel<DeliveryState, DeliveryStateStatus> {
  final DeliveriesRepository deliveriesRepository;

  StreamSubscription<List<ExDelivery>>? deliveryPointExListSubscription;

  DeliveryViewModel(this.deliveriesRepository) : super(DeliveryState());

  @override
  DeliveryStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    deliveryPointExListSubscription = deliveriesRepository.watchExDeliveries().listen((event) {
      emit(state.copyWith(status: DeliveryStateStatus.dataLoaded, deliveries: event));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await deliveryPointExListSubscription?.cancel();
  }
}
