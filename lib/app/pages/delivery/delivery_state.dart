part of 'delivery_page.dart';

enum DeliveryStateStatus {
  initial,
  dataLoaded,
}

class DeliveryState {
  DeliveryState({
    this.status = DeliveryStateStatus.initial,
    this.deliveries = const []
  });

  final List<ExDelivery> deliveries;
  final DeliveryStateStatus status;

  DeliveryState copyWith({
    DeliveryStateStatus? status,
    List<ExDelivery>? deliveries
  }) {
    return DeliveryState(
      status: status ?? this.status,
      deliveries: deliveries ?? this.deliveries,
    );
  }
}
