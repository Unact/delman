import 'package:equatable/equatable.dart';

import 'package:delman/app/utils/nullify.dart';

class Delivery extends Equatable {
  final int id;
  final int active;
  final DateTime deliveryDate;

  const Delivery({
    required this.id,
    required this.active,
    required this.deliveryDate
  });

  bool get isActive => active == 1;

  @override
  List<Object> get props => [id, active];

  static Delivery fromJson(dynamic json) {
    return Delivery(
      id: json['id'],
      deliveryDate: Nullify.parseDate(json['deliveryDate'])!,
      active: json['active']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryDate': deliveryDate.toIso8601String(),
      'active': active
    };
  }

  @override
  String toString() => 'Delivery { id: $id }';
}
