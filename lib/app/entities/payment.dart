import 'package:equatable/equatable.dart';

import 'package:delman/app/utils/nullify.dart';

class Payment extends Equatable {
  final int? id;
  final int deliveryPointOrderId;
  final double summ;
  final String? transactionId;

  const Payment({
    this.id,
    required this.deliveryPointOrderId,
    required this.summ,
    this.transactionId
  });

  bool get isCard => transactionId != null;

  @override
  List<Object?> get props => [
    id,
    deliveryPointOrderId,
    summ,
    transactionId,
  ];

  factory Payment.fromJson(dynamic json) {
    return Payment(
      id: json['id'],
      deliveryPointOrderId: json['deliveryPointOrderId'],
      summ: Nullify.parseDouble(json['summ'])!,
      transactionId: json['transactionId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryPointOrderId': deliveryPointOrderId,
      'summ': summ,
      'transactionId': transactionId
    };
  }

  @override
  String toString() => 'Payment { id: $id }';
}
