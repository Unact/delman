import 'package:equatable/equatable.dart';

import 'package:delman/app/utils/nullify.dart';

class OrderInfo extends Equatable {
  final int? id;
  final int orderId;
  final String comment;
  final DateTime ts;

  const OrderInfo({
    this.id,
    required this.orderId,
    required this.comment,
    required this.ts
  });

  @override
  List<Object> get props => [orderId, comment, ts];

  static OrderInfo fromJson(dynamic json) {
    return OrderInfo(
      id: json['id'],
      orderId: json['orderId'],
      comment: json['comment'],
      ts: Nullify.parseDate(json['ts'])!
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'comment': comment,
      'ts': ts.toIso8601String()
    };
  }

  @override
  String toString() => 'OrderInfo { id: $id }';
}
