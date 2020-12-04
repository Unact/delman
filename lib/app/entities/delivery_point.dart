import 'package:equatable/equatable.dart';

import 'package:delman/app/utils/nullify.dart';

class DeliveryPoint extends Equatable {
  final int id;
  final int deliveryId;
  final int seq;
  final DateTime planArrival;
  final DateTime planDeparture;
  final DateTime factArrival;
  final DateTime factDeparture;
  final String addressName;
  final double latitude;
  final double longitude;

  final String phone;
  final String paymentTypeName;
  final String buyerName;
  final String sellerName;
  final String deliveryTypeName;

  const DeliveryPoint({
    this.id,
    this.deliveryId,
    this.seq,
    this.planArrival,
    this.planDeparture,
    this.factArrival,
    this.factDeparture,
    this.addressName,
    this.latitude,
    this.longitude,
    this.phone,
    this.paymentTypeName,
    this.buyerName,
    this.sellerName,
    this.deliveryTypeName
  });

  bool get inProgress => factArrival != null;
  bool get isFinished => factDeparture != null;

  @override
  List<Object> get props => [
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
  ];

  static DeliveryPoint fromJson(dynamic map) {
    return DeliveryPoint(
      id: map['id'],
      deliveryId: map['deliveryId'],
      seq: map['seq'],
      planArrival: Nullify.parseDate(map['planArrival']),
      planDeparture: Nullify.parseDate(map['planDeparture']),
      factArrival: Nullify.parseDate(map['factArrival']),
      factDeparture: Nullify.parseDate(map['factDeparture']),
      addressName: map['addressName'],
      latitude: Nullify.parseDouble(map['latitude']),
      longitude: Nullify.parseDouble(map['longitude']),
      phone: map['phone'],
      paymentTypeName: map['paymentTypeName'],
      buyerName: map['buyerName'],
      sellerName: map['sellerName'],
      deliveryTypeName: map['deliveryTypeName']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deliveryId': deliveryId,
      'seq': seq,
      'planArrival': planArrival?.toIso8601String(),
      'planDeparture': planDeparture?.toIso8601String(),
      'factArrival': factArrival?.toIso8601String(),
      'factDeparture': factDeparture?.toIso8601String(),
      'addressName': addressName,
      'latitude': latitude,
      'longitude': longitude,
      'phone' : phone,
      'paymentTypeName' : paymentTypeName,
      'buyerName' : buyerName,
      'sellerName' : sellerName,
      'deliveryTypeName' : deliveryTypeName,
    };
  }

  @override
  String toString() => 'DeliveryPoint { id: $id }';
}
