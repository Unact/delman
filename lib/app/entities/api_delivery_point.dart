part of 'entities.dart';

class ApiDeliveryPoint extends Equatable {
  final int id;
  final int deliveryId;
  final int seq;
  final DateTime planArrival;
  final DateTime planDeparture;
  final DateTime? factArrival;
  final DateTime? factDeparture;
  final String addressName;
  final double latitude;
  final double longitude;

  final String? sellerName;
  final String? buyerName;
  final String? phone;
  final String? paymentTypeName;
  final String? deliveryTypeName;

  final String? pickupSellerName;
  final String? senderName;
  final String? senderPhone;

  const ApiDeliveryPoint({
    required this.id,
    required this.deliveryId,
    required this.seq,
    required this.planArrival,
    required this.planDeparture,
    this.factArrival,
    this.factDeparture,
    required this.addressName,
    required this.latitude,
    required this.longitude,
    this.phone,
    this.paymentTypeName,
    this.buyerName,
    this.sellerName,
    this.deliveryTypeName,
    this.pickupSellerName,
    this.senderName,
    this.senderPhone,
  });

  factory ApiDeliveryPoint.fromJson(dynamic map) {
    return ApiDeliveryPoint(
      id: map['id'],
      deliveryId: map['deliveryId'],
      seq: map['seq'],
      planArrival: Parsing.parseDate(map['planArrival'])!,
      planDeparture: Parsing.parseDate(map['planDeparture'])!,
      factArrival: Parsing.parseDate(map['factArrival']),
      factDeparture: Parsing.parseDate(map['factDeparture']),
      addressName: map['addressName'],
      latitude: Parsing.parseDouble(map['latitude'])!,
      longitude: Parsing.parseDouble(map['longitude'])!,
      phone: map['phone'],
      paymentTypeName: map['paymentTypeName'],
      buyerName: map['buyerName'],
      sellerName: map['sellerName'],
      deliveryTypeName: map['deliveryTypeName'],
      pickupSellerName: map['pickupSellerName'],
      senderName: map['senderName'],
      senderPhone: map['senderPhone'],
    );
  }

  DeliveryPoint toDatabaseEnt() {
    return DeliveryPoint(
      id: id,
      deliveryId: deliveryId,
      seq: seq,
      planArrival: planArrival,
      planDeparture: planDeparture,
      factArrival: factArrival,
      factDeparture: factDeparture,
      addressName: addressName,
      latitude: latitude,
      longitude: longitude,
      phone: phone,
      paymentTypeName: paymentTypeName,
      buyerName: buyerName,
      sellerName: sellerName,
      deliveryTypeName: deliveryTypeName,
      pickupSellerName: pickupSellerName,
      senderName: senderName,
      senderPhone: senderPhone,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deliveryId,
    seq,
    planArrival,
    planDeparture,
    factArrival,
    factDeparture,
    addressName,
    latitude,
    longitude,
    sellerName,
    buyerName,
    phone,
    paymentTypeName,
    deliveryTypeName,
    pickupSellerName,
    senderName,
    senderPhone,
  ];
}
