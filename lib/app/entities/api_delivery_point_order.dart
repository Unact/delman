part of 'entities.dart';

class ApiDeliveryPointOrder {
  final int id;
  final int deliveryPointId;
  final int orderId;
  final int? canceled;
  final int? finished;
  final int pickup;

  const ApiDeliveryPointOrder({
    required this.id,
    required this.deliveryPointId,
    required this.orderId,
    required this.canceled,
    required this.finished,
    required this.pickup,
  });

  factory ApiDeliveryPointOrder.fromJson(dynamic map) {
    return ApiDeliveryPointOrder(
      id: map['id'],
      deliveryPointId: map['deliveryPointId'],
      orderId: map['orderId'],
      canceled: map['canceled'],
      finished: map['finished'],
      pickup: map['pickup'],
    );
  }

  DeliveryPointOrder toDatabaseEnt() {
    return DeliveryPointOrder(
      id: id,
      deliveryPointId: deliveryPointId,
      orderId: orderId,
      pickup: pickup == 1,
      finished: finished == 1,
      canceled: canceled == 1
    );
  }
}
