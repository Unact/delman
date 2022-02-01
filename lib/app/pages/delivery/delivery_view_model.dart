part of 'delivery_page.dart';

class DeliveryViewModel extends PageViewModel<DeliveryState, DeliveryStateStatus> {
  DeliveryViewModel(BuildContext context) : super(context, DeliveryState());

  @override
  DeliveryStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.deliveryPoints,
  ]);

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: DeliveryStateStatus.dataLoaded,
      deliveries: await app.storage.deliveriesDao.getExDeliveries()
    ));
  }
}
