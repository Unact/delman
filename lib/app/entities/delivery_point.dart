import 'package:equatable/equatable.dart';
import 'package:quiver/core.dart';

import 'package:delman/app/utils/nullify.dart';

class DeliveryPoint extends Equatable {
  final int id;
  final int deliveryId;
  final int seq;
  final DateTime? planArrival;
  final DateTime? planDeparture;
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

  const DeliveryPoint({
    required this.id,
    required this.deliveryId,
    required this.seq,
    this.planArrival,
    this.planDeparture,
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

  bool get inProgress => factArrival != null;
  bool get isFinished => factDeparture != null;

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
    phone,
    paymentTypeName,
    buyerName,
    sellerName,
    deliveryTypeName,
    pickupSellerName,
    senderName,
    senderPhone,
  ];

  factory DeliveryPoint.fromJson(dynamic map) {
    return DeliveryPoint(
      id: map['id'],
      deliveryId: map['deliveryId'],
      seq: map['seq'],
      planArrival: Nullify.parseDate(map['planArrival']),
      planDeparture: Nullify.parseDate(map['planDeparture']),
      factArrival: Nullify.parseDate(map['factArrival']),
      factDeparture: Nullify.parseDate(map['factDeparture']),
      addressName: map['addressName'],
      latitude: Nullify.parseDouble(map['latitude'])!,
      longitude: Nullify.parseDouble(map['longitude'])!,
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
      'pickupSellerName': pickupSellerName,
      'senderName': senderName,
      'senderPhone': senderPhone,
    };
  }

  DeliveryPoint copyWith({
    int? id,
    int? deliveryId,
    int? seq,
    Optional<DateTime>? planArrival,
    Optional<DateTime>? planDeparture,
    Optional<DateTime>? factArrival,
    Optional<DateTime>? factDeparture,
    String? addressName,
    double? latitude,
    double? longitude,
    String? phone,
    String? paymentTypeName,
    String? buyerName,
    String? sellerName,
    String? deliveryTypeName,
    String? pickupSellerName,
    String? senderName,
    String? senderPhone,
  }) {
    return DeliveryPoint(
      id: id ?? this.id,
      deliveryId: deliveryId ?? this.deliveryId,
      seq: seq ?? this.seq,
      planArrival: planArrival != null ? planArrival.orNull : this.planArrival,
      planDeparture: planDeparture != null ? planDeparture.orNull : this.planDeparture,
      factArrival: factArrival != null ? factArrival.orNull : this.factArrival,
      factDeparture: factDeparture != null ? factDeparture.orNull : this.factDeparture,
      addressName: addressName ?? this.addressName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phone: phone ?? this.phone,
      paymentTypeName: paymentTypeName ?? this.paymentTypeName,
      buyerName: buyerName ?? this.buyerName,
      sellerName: sellerName ?? this.sellerName,
      deliveryTypeName: deliveryTypeName ?? this.deliveryTypeName,
      pickupSellerName: pickupSellerName ?? this.pickupSellerName,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
    );
  }

  @override
  String toString() => 'DeliveryPoint { id: $id }';
}
