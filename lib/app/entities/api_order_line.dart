part of 'entities.dart';

class ApiOrderLine {
  final int id;
  final int orderId;
  final String name;
  final int amount;
  final double price;
  final int? factAmount;

  const ApiOrderLine({
    required this.id,
    required this.orderId,
    required this.name,
    required this.amount,
    required this.price,
    this.factAmount
  });

  factory ApiOrderLine.fromJson(dynamic json) {
    return ApiOrderLine(
      id: json['id'],
      orderId: json['orderId'],
      name: json['name'],
      amount: json['amount'],
      price: Parsing.parseDouble(json['price'])!,
      factAmount: json['factAmount'],
    );
  }

  OrderLine toDatabaseEnt() {
    return OrderLine(
      id: id,
      orderId: orderId,
      name: name,
      amount: amount,
      price: price,
      factAmount: factAmount
    );
  }
}
