part of 'point_address_page.dart';

enum PointAddressStateStatus {
  initial,
  dataLoaded,
  failure,
  selectionChange,
}

class PointAddressState {
  PointAddressState({
    this.status = PointAddressStateStatus.initial,
    required this.deliveryPointEx,
    this.allPoints = const [],
    this.message = ''
  });

  final PointAddressStateStatus status;
  final DeliveryPointExResult deliveryPointEx;
  final List<DeliveryPointExResult> allPoints;
  final String message;

  PointAddressState copyWith({
    PointAddressStateStatus? status,
    DeliveryPointExResult? deliveryPointEx,
    List<DeliveryPointExResult>? allPoints,
    String? message
  }) {
    return PointAddressState(
      status: status ?? this.status,
      deliveryPointEx: deliveryPointEx ?? this.deliveryPointEx,
      allPoints: allPoints ?? this.allPoints,
      message: message ?? this.message,
    );
  }
}
