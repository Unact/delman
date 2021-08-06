import 'package:equatable/equatable.dart';
import 'package:quiver/core.dart';

import 'package:delman/app/utils/nullify.dart';

class Order extends Equatable {
  final int id;
  final DateTime? deliveryDateTimeFrom;
  final DateTime? deliveryDateTimeTo;
  final DateTime? pickupDateTimeFrom;
  final DateTime? pickupDateTimeTo;
  final String number;
  final String trackingNumber;
  final String? senderName;
  final String? buyerName;
  final String? senderPhone;
  final String? buyerPhone;
  final String? comment;
  final String deliveryTypeName;
  final String pickupTypeName;
  final int? senderFloor;
  final int? buyerFloor;
  final String? senderFlat;
  final String? buyerFlat;
  final int? senderElevator;
  final int? buyerElevator;
  final String paymentTypeName;
  final String sellerName;
  final int documentsReturn;
  final int cardPaymentAllowed;
  final int? storageId;
  final String deliveryAddressName;
  final String pickupAddressName;

  const Order({
    required this.id,
    this.deliveryDateTimeFrom,
    this.deliveryDateTimeTo,
    this.pickupDateTimeFrom,
    this.pickupDateTimeTo,
    required this.number,
    required this.trackingNumber,
    this.senderName,
    this.buyerName,
    this.senderPhone,
    this.buyerPhone,
    this.comment,
    required this.deliveryTypeName,
    required this.pickupTypeName,
    this.senderFloor,
    this.buyerFloor,
    this.senderFlat,
    this.buyerFlat,
    this.senderElevator,
    this.buyerElevator,
    required this.paymentTypeName,
    required this.sellerName,
    required this.documentsReturn,
    required this.cardPaymentAllowed,
    this.storageId,
    required this.deliveryAddressName,
    required this.pickupAddressName,
  });

  bool get hasSenderElevator => senderElevator == 1;
  bool get hasBuyerElevator => buyerElevator == 1;
  bool get isCardPaymentAllowed => cardPaymentAllowed == 1;
  bool get needDocumentsReturn => documentsReturn == 1;

  @override
  List<Object?> get props => [
    id,
    deliveryDateTimeFrom,
    deliveryDateTimeTo,
    pickupDateTimeFrom,
    pickupDateTimeTo,
    number,
    trackingNumber,
    senderName,
    buyerName,
    senderPhone,
    buyerPhone,
    comment,
    deliveryTypeName,
    pickupTypeName,
    senderFloor,
    buyerFloor,
    senderFlat,
    buyerFlat,
    senderElevator,
    buyerElevator,
    paymentTypeName,
    sellerName,
    documentsReturn,
    cardPaymentAllowed,
    storageId,
    deliveryAddressName,
    pickupAddressName,
  ];

  static Order fromJson(dynamic json) {
    return Order(
      id: json['id'],
      deliveryDateTimeFrom: Nullify.parseDate(json['deliveryDateTimeFrom']),
      deliveryDateTimeTo: Nullify.parseDate(json['deliveryDateTimeTo']),
      pickupDateTimeFrom: Nullify.parseDate(json['pickupDateTimeFrom']),
      pickupDateTimeTo: Nullify.parseDate(json['pickupDateTimeTo']),
      number: json['number'],
      trackingNumber: json['trackingNumber'],
      senderName: json['senderName'],
      buyerName: json['buyerName'],
      senderPhone: json['senderPhone'],
      buyerPhone: json['buyerPhone'],
      comment: json['comment'],
      deliveryTypeName: json['deliveryTypeName'],
      pickupTypeName: json['pickupTypeName'],
      senderFloor: json['senderFloor'],
      buyerFloor: json['buyerFloor'],
      senderFlat: json['senderFlat'],
      buyerFlat: json['buyerFlat'],
      senderElevator: json['senderElevator'],
      buyerElevator: json['buyerElevator'],
      paymentTypeName: json['paymentTypeName'],
      sellerName: json['sellerName'],
      documentsReturn: json['documentsReturn'],
      cardPaymentAllowed: json['cardPaymentAllowed'],
      storageId: json['storageId'],
      deliveryAddressName: json['deliveryAddressName'],
      pickupAddressName: json['pickupAddressName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryDateTimeFrom': deliveryDateTimeFrom?.toIso8601String(),
      'deliveryDateTimeTo': deliveryDateTimeTo?.toIso8601String(),
      'pickupDateTimeFrom': pickupDateTimeFrom?.toIso8601String(),
      'pickupDateTimeTo': pickupDateTimeTo?.toIso8601String(),
      'number': number,
      'trackingNumber': trackingNumber,
      'senderName': senderName,
      'buyerName': buyerName,
      'senderPhone': senderPhone,
      'buyerPhone': buyerPhone,
      'comment': comment,
      'deliveryTypeName': deliveryTypeName,
      'pickupTypeName': pickupTypeName,
      'senderFloor': senderFloor,
      'buyerFloor': buyerFloor,
      'senderFlat': senderFlat,
      'buyerFlat': buyerFlat,
      'senderElevator': senderElevator,
      'buyerElevator': buyerElevator,
      'paymentTypeName': paymentTypeName,
      'sellerName': sellerName,
      'documentsReturn': documentsReturn,
      'cardPaymentAllowed': cardPaymentAllowed,
      'storageId': storageId,
      'deliveryAddressName': deliveryAddressName,
      'pickupAddressName': pickupAddressName,
    };
  }

  Order copyWith({
    int? id,
    int? orderId,
    Optional<DateTime>? deliveryDateTimeFrom,
    Optional<DateTime>? deliveryDateTimeTo,
    Optional<DateTime>? pickupDateTimeFrom,
    Optional<DateTime>? pickupDateTimeTo,
    String? number,
    String? trackingNumber,
    Optional<String>? senderName,
    Optional<String>? buyerName,
    Optional<String>? senderPhone,
    Optional<String>? buyerPhone,
    String? comment,
    String? deliveryTypeName,
    String? pickupTypeName,
    Optional<int>? senderFloor,
    Optional<int>? buyerFloor,
    Optional<String>? senderFlat,
    Optional<String>? buyerFlat,
    Optional<int>? senderElevator,
    Optional<int>? buyerElevator,
    String? paymentTypeName,
    String? sellerName,
    int? documentsReturn,
    int? cardPaymentAllowed,
    Optional<int>? storageId,
    String? deliveryAddressName,
    String? pickupAddressName
  }) {
    return Order(
      id: id ?? this.id,
      deliveryDateTimeFrom: deliveryDateTimeFrom != null ? deliveryDateTimeFrom.orNull : this.deliveryDateTimeFrom,
      deliveryDateTimeTo: deliveryDateTimeTo != null ? deliveryDateTimeTo.orNull : this.deliveryDateTimeTo,
      pickupDateTimeFrom: pickupDateTimeFrom != null ? pickupDateTimeFrom.orNull : this.pickupDateTimeFrom,
      pickupDateTimeTo: pickupDateTimeTo != null ? pickupDateTimeTo.orNull : this.pickupDateTimeTo,
      number: number ?? this.number,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      senderName: senderName != null ? senderName.orNull : this.senderName,
      buyerName: buyerName != null ? buyerName.orNull : this.buyerName,
      senderPhone: senderPhone != null ? senderPhone.orNull : this.senderPhone,
      buyerPhone: buyerPhone != null ? buyerPhone.orNull : this.buyerPhone,
      comment: comment ?? this.comment,
      deliveryTypeName: deliveryTypeName ?? this.deliveryTypeName,
      pickupTypeName: pickupTypeName ?? this.pickupTypeName,
      senderFloor: senderFloor != null ? senderFloor.orNull : this.senderFloor,
      buyerFloor: buyerFloor != null ? buyerFloor.orNull : this.buyerFloor,
      senderFlat: senderFlat != null ? senderFlat.orNull : this.senderFlat,
      buyerFlat: buyerFlat != null ? buyerFlat.orNull : this.buyerFlat,
      senderElevator: senderElevator != null ? senderElevator.orNull : this.senderElevator,
      buyerElevator: buyerElevator != null ? buyerElevator.orNull : this.buyerElevator,
      paymentTypeName: paymentTypeName ?? this.paymentTypeName,
      sellerName: sellerName ?? this.sellerName,
      documentsReturn: documentsReturn ?? this.documentsReturn,
      cardPaymentAllowed: cardPaymentAllowed ?? this.cardPaymentAllowed,
      storageId: storageId != null ? storageId.orNull : this.storageId,
      deliveryAddressName: deliveryAddressName ?? this.deliveryAddressName,
      pickupAddressName: pickupAddressName ?? this.pickupAddressName,
    );
  }

  @override
  String toString() => 'Order { id: $id }';
}
