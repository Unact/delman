import 'package:equatable/equatable.dart';

class DeliveryPointOrder extends Equatable {
  final int id;
  final int deliveryPointId;
  final int orderId;
  final int canceled;
  final int finished;
  final int pickup;

  const DeliveryPointOrder({
    required this.id,
    required this.deliveryPointId,
    required this.orderId,
    required this.canceled,
    required this.finished,
    required this.pickup,
  });

  bool get isFinished => finished == 1;
  bool get isCanceled => canceled == 1;
  bool get isPickup => pickup == 1;

  @override
  List<Object> get props => [
    id,
    deliveryPointId,
    orderId,
    canceled,
    finished,
    pickup,
  ];

  factory DeliveryPointOrder.fromJson(dynamic map) {
    return DeliveryPointOrder(
      id: map['id'],
      deliveryPointId: map['deliveryPointId'],
      orderId: map['orderId'],
      canceled: map['canceled'],
      finished: map['finished'],
      pickup: map['pickup'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryPointId': deliveryPointId,
      'orderId': orderId,
      'canceled': canceled,
      'finished': finished,
      'pickup': pickup,
    };
  }

  DeliveryPointOrder copyWith({
    int? id,
    int? deliveryPointId,
    int? orderId,
    int? canceled,
    int? finished,
    int? pickup,
  }) {
    return DeliveryPointOrder(
      id: id ?? this.id,
      deliveryPointId: deliveryPointId ?? this.deliveryPointId,
      orderId: orderId ?? this.orderId,
      canceled: canceled ?? this.canceled,
      finished: finished ?? this.finished,
      pickup: pickup ?? this.pickup,
    );
  }

  @override
  String toString() => 'DeliveryPointOrder { id: $id }';
}
