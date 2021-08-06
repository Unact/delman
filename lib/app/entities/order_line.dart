import 'package:equatable/equatable.dart';
import 'package:quiver/core.dart';

import 'package:delman/app/utils/nullify.dart';

class OrderLine extends Equatable {
  final int id;
  final int orderId;
  final String name;
  final int amount;
  final double price;
  final int? factAmount;

  const OrderLine({
    required this.id,
    required this.orderId,
    required this.name,
    required this.amount,
    required this.price,
    this.factAmount
  });

  int get currentAmount => factAmount ?? amount;

  @override
  List<Object?> get props => [
    id,
    orderId,
    name,
    amount,
    price,
    factAmount,
  ];

  factory OrderLine.fromJson(dynamic json) {
    return OrderLine(
      id: json['id'],
      orderId: json['orderId'],
      name: json['name'],
      amount: json['amount'],
      price: Nullify.parseDouble(json['price'])!,
      factAmount: json['factAmount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'name': name,
      'amount': amount,
      'price': price,
      'factAmount': factAmount,
    };
  }

  OrderLine copyWith({
    int? id,
    int? orderId,
    String? name,
    int? amount,
    double? price,
    Optional<int>? factAmount,
  }) {
    return OrderLine(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      factAmount: factAmount != null ? factAmount.orNull : this.factAmount,
    );
  }

  @override
  String toString() => 'OrderLine { id: $id }';
}
