import 'package:equatable/equatable.dart';

import 'package:delman/app/utils/nullify.dart';

class Order extends Equatable {
  final int id;
  final int deliveryPointId;
  final int deliveryPointOrderId;
  final DateTime deliveryFrom;
  final DateTime deliveryTo;
  final String number;
  final String trackingNumber;
  final String buyerName;
  final String phone;
  final String comment;
  final String deliveryTypeName;
  final int floor;
  final String flat;
  final int elevator;
  final String paymentTypeName;
  final String sellerName;
  final int canceled;
  final int finished;

  const Order({
    this.id,
    this.deliveryPointId,
    this.deliveryPointOrderId,
    this.deliveryFrom,
    this.deliveryTo,
    this.number,
    this.trackingNumber,
    this.buyerName,
    this.phone,
    this.comment,
    this.deliveryTypeName,
    this.floor,
    this.flat,
    this.elevator,
    this.paymentTypeName,
    this.sellerName,
    this.canceled,
    this.finished,
  });

  bool get hasElevator => elevator == 1;
  bool get isFinished => finished == 1;
  bool get isCanceled => canceled == 1;

  @override
  List<Object> get props => [
    id,
    deliveryPointId,
    deliveryPointOrderId,
    deliveryFrom,
    deliveryTo,
    number,
    trackingNumber,
    buyerName,
    phone,
    comment,
    deliveryTypeName,
    floor,
    flat,
    elevator,
    paymentTypeName,
    sellerName,
    canceled,
    finished,
  ];

  static Order fromJson(dynamic json) {
    return Order(
      id: json['id'],
      deliveryPointId: json['deliveryPointId'],
      deliveryPointOrderId: json['deliveryPointOrderId'],
      deliveryFrom: Nullify.parseDate(json['deliveryFrom']),
      deliveryTo: Nullify.parseDate(json['deliveryTo']),
      number: json['number'],
      trackingNumber: json['trackingNumber'],
      buyerName: json['buyerName'],
      phone: json['phone'],
      comment: json['comment'],
      deliveryTypeName: json['deliveryTypeName'],
      floor: json['floor'],
      flat: json['flat'],
      elevator: json['elevator'],
      paymentTypeName: json['paymentTypeName'],
      sellerName: json['sellerName'],
      canceled: json['canceled'],
      finished: json['finished'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryPointId': deliveryPointId,
      'deliveryPointOrderId': deliveryPointOrderId,
      'deliveryFrom': deliveryFrom?.toIso8601String(),
      'deliveryTo': deliveryTo?.toIso8601String(),
      'number': number,
      'trackingNumber': trackingNumber,
      'buyerName': buyerName,
      'phone': phone,
      'comment': comment,
      'deliveryTypeName': deliveryTypeName,
      'floor': floor,
      'flat': flat,
      'elevator': elevator,
      'paymentTypeName': paymentTypeName,
      'sellerName': sellerName,
      'canceled': canceled,
      'finished': finished,
    };
  }

  @override
  String toString() => 'Order { id: $id }';
}
