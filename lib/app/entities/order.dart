import 'package:equatable/equatable.dart';

import 'package:delman/app/utils/nullify.dart';

class Order extends Equatable {
  final int id;
  final int orderId;
  final int deliveryPointId;
  final int pickup;
  final DateTime? timeFrom;
  final DateTime? timeTo;
  final String number;
  final String trackingNumber;
  final String? personName;
  final String? phone;
  final String? comment;
  final String deliveryTypeName;
  final int? floor;
  final String? flat;
  final int? elevator;
  final String paymentTypeName;
  final String sellerName;
  final int canceled;
  final int finished;
  final int cardPaymentAllowed;
  final int? orderStorageId;

  const Order({
    required this.id,
    required this.orderId,
    required this.deliveryPointId,
    required this.pickup,
    this.timeFrom,
    this.timeTo,
    required this.number,
    required this.trackingNumber,
    this.personName,
    this.phone,
    this.comment,
    required this.deliveryTypeName,
    this.floor,
    this.flat,
    this.elevator,
    required this.paymentTypeName,
    required this.sellerName,
    required this.canceled,
    required this.finished,
    required this.cardPaymentAllowed,
    this.orderStorageId
  });

  bool get hasElevator => elevator == 1;
  bool get isFinished => finished == 1;
  bool get isCanceled => canceled == 1;
  bool get isPickup => pickup == 1;
  bool get isCardPaymentAllowed => cardPaymentAllowed == 1;

  @override
  List<Object> get props => [
    id,
    orderId,
    deliveryPointId,
    pickup,
    number,
    trackingNumber,
    deliveryTypeName,
    paymentTypeName,
    sellerName,
    canceled,
    finished,
    cardPaymentAllowed,
  ];

  static Order fromJson(dynamic json) {
    return Order(
      id: json['id'],
      orderId: json['orderId'],
      deliveryPointId: json['deliveryPointId'],
      pickup: json['pickup'],
      timeFrom: Nullify.parseDate(json['timeFrom']),
      timeTo: Nullify.parseDate(json['timeTo']),
      number: json['number'],
      trackingNumber: json['trackingNumber'],
      personName: json['personName'],
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
      cardPaymentAllowed: json['cardPaymentAllowed'],
      orderStorageId: json['orderStorageId']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'deliveryPointId': deliveryPointId,
      'pickup': pickup,
      'timeFrom': timeFrom?.toIso8601String(),
      'timeTo': timeTo?.toIso8601String(),
      'number': number,
      'trackingNumber': trackingNumber,
      'personName': personName,
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
      'cardPaymentAllowed': cardPaymentAllowed,
      'orderStorageId': orderStorageId
    };
  }

  Order copyWith({
    int? id,
    int? orderId,
    int? deliveryPointId,
    int? pickup,
    DateTime? timeFrom,
    DateTime? timeTo,
    String? number,
    String? trackingNumber,
    String? personName,
    String? phone,
    String? comment,
    String? deliveryTypeName,
    int? floor,
    String? flat,
    int? elevator,
    String? paymentTypeName,
    String? sellerName,
    int? canceled,
    int? finished,
    int? cardPaymentAllowed,
    int? orderStorageId
  }) {
    return Order(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      deliveryPointId: deliveryPointId ?? this.deliveryPointId,
      pickup: pickup ?? this.pickup,
      timeFrom: timeFrom ?? this.timeFrom,
      timeTo: timeTo ?? this.timeTo,
      number: number ?? this.number,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      personName: personName ?? this.personName,
      phone: phone ?? this.phone,
      comment: comment ?? this.comment,
      deliveryTypeName: deliveryTypeName ?? this.deliveryTypeName,
      floor: floor ?? this.floor,
      flat: flat ?? this.flat,
      elevator: elevator ?? this.elevator,
      paymentTypeName: paymentTypeName ?? this.paymentTypeName,
      sellerName: sellerName ?? this.sellerName,
      canceled: canceled ?? this.canceled,
      finished: finished ?? this.finished,
      cardPaymentAllowed: cardPaymentAllowed ?? this.cardPaymentAllowed,
      orderStorageId: orderStorageId ?? this.orderStorageId
    );
  }

  @override
  String toString() => 'Order { id: $id }';
}
