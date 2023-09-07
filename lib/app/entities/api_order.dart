part of 'entities.dart';

class ApiOrder {
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
  final int packages;
  final int needPayment;
  final int factsConfirmed;
  final int deliveryLoadDuration;
  final int pickupLoadDuration;
  final String? productArrivalName;
  final String? productArrivalQR;

  const ApiOrder({
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
    required this.packages,
    required this.needPayment,
    required this.factsConfirmed,
    required this.deliveryLoadDuration,
    required this.pickupLoadDuration,
    required this.productArrivalName,
    required this.productArrivalQR
  });

  static ApiOrder fromJson(dynamic json) {
    return ApiOrder(
      id: json['id'],
      deliveryDateTimeFrom: Parsing.parseDate(json['deliveryDateTimeFrom']),
      deliveryDateTimeTo: Parsing.parseDate(json['deliveryDateTimeTo']),
      pickupDateTimeFrom: Parsing.parseDate(json['pickupDateTimeFrom']),
      pickupDateTimeTo: Parsing.parseDate(json['pickupDateTimeTo']),
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
      packages: json['packages'],
      needPayment: json['needPayment'],
      factsConfirmed: json['factsConfirmed'],
      deliveryLoadDuration: json['deliveryLoadDuration'],
      pickupLoadDuration: json['pickupLoadDuration'],
      productArrivalName: json['productArrivalName'],
      productArrivalQR: json['productArrivalQR']
    );
  }

  Order toDatabaseEnt() {
    return Order(
      id: id,
      deliveryDateTimeFrom: deliveryDateTimeFrom,
      deliveryDateTimeTo: deliveryDateTimeTo,
      pickupDateTimeFrom: pickupDateTimeFrom,
      pickupDateTimeTo: pickupDateTimeTo,
      number: number,
      trackingNumber: trackingNumber,
      senderName: senderName,
      buyerName: buyerName,
      senderPhone: senderPhone,
      buyerPhone: buyerPhone,
      comment: comment,
      deliveryTypeName: deliveryTypeName,
      pickupTypeName: pickupTypeName,
      senderFloor: senderFloor,
      buyerFloor: buyerFloor,
      senderFlat: senderFlat,
      buyerFlat: buyerFlat,
      senderElevator: senderElevator == 1,
      buyerElevator: buyerElevator == 1,
      paymentTypeName: paymentTypeName,
      sellerName: sellerName,
      documentsReturn: documentsReturn == 1,
      cardPaymentAllowed: cardPaymentAllowed == 1,
      storageId: storageId,
      deliveryAddressName: deliveryAddressName,
      pickupAddressName: pickupAddressName,
      packages: packages,
      needPayment: needPayment == 1,
      factsConfirmed: factsConfirmed == 1,
      deliveryLoadDuration: deliveryLoadDuration,
      pickupLoadDuration: pickupLoadDuration,
      productArrivalName: productArrivalName,
      productArrivalQR: productArrivalQR
    );
  }
}
