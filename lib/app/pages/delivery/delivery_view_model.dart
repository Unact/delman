part of 'delivery_page.dart';

class DeliveryViewModel extends PageViewModel<DeliveryState> {
  DeliveryViewModel(BuildContext context) : super(context, DeliveryInitial());

  List<Delivery> get deliveries => appViewModel.deliveries..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
  List<DeliveryPoint> getDeliveryPointsForDelivery(Delivery delivery) {
    return appViewModel.deliveryPoints
      .where((e) => e.deliveryId == delivery.id)
      .toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
  }
}
