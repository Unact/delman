part of 'entities.dart';

class ApiOrderInfoLine {
  final int id;
  final int orderId;
  final String comment;
  final DateTime ts;

  const ApiOrderInfoLine({
    required this.id,
    required this.orderId,
    required this.comment,
    required this.ts
  });

  factory ApiOrderInfoLine.fromJson(dynamic json) {
    return ApiOrderInfoLine(
      id: json['id'],
      orderId: json['orderId'],
      comment: json['comment'],
      ts: Parsing.parseDate(json['ts'])!
    );
  }

  OrderInfoLine toDatabaseEnt() {
    return OrderInfoLine(
      id: id,
      orderId: orderId,
      comment: comment,
      ts: ts
    );
  }
}
