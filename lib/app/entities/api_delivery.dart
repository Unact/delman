part of 'entities.dart';

class ApiDelivery {
  final int id;
  final int active;
  final DateTime deliveryDate;

  const ApiDelivery({
    required this.id,
    required this.active,
    required this.deliveryDate
  });

  factory ApiDelivery.fromJson(dynamic json) {
    return ApiDelivery(
      id: json['id'],
      deliveryDate: Parsing.parseDate(json['deliveryDate'])!,
      active: json['active']
    );
  }

  Delivery toDatabaseEnt() {
    return Delivery(
      id: id,
      active: active == 1,
      deliveryDate: deliveryDate
    );
  }
}
