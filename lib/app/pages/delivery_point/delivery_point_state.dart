part of 'delivery_point_page.dart';

enum DeliveryPointStateStatus {
  initial,
  dataLoaded,
  orderDataCopied,
  inProgress,
  arrivalSaved,
  failure
}

extension DeliveryPointStateStatusX on DeliveryPointStateStatus {
  bool get isInitial => this == DeliveryPointStateStatus.initial;
  bool get isDataLoaded => this == DeliveryPointStateStatus.dataLoaded;
  bool get isOrderDataCopied => this == DeliveryPointStateStatus.orderDataCopied;
  bool get isInProgress => this == DeliveryPointStateStatus.inProgress;
  bool get isArrivalSaved => this == DeliveryPointStateStatus.arrivalSaved;
  bool get isFailure => this == DeliveryPointStateStatus.failure;
}

class DeliveryPointState {
  DeliveryPointState({
    this.status = DeliveryPointStateStatus.initial,
    required this.deliveryPointEx,
    this.deliveryPointOrdersEx = const [],
    this.message = ''
  });

  final DeliveryPointStateStatus status;
  final DeliveryPointExResult deliveryPointEx;
  final List<DeliveryPointOrderExResult> deliveryPointOrdersEx;
  final String message;

  List<DeliveryPointOrderExResult> get deliveryOrders => deliveryPointOrdersEx.where((el) => !el.dpo.pickup).toList();
  List<DeliveryPointOrderExResult> get pickupPointOrders => deliveryPointOrdersEx.where((el) => el.dpo.pickup).toList();

  DeliveryPointState copyWith({
    DeliveryPointStateStatus? status,
    DeliveryPointExResult? deliveryPointEx,
    List<DeliveryPointOrderExResult>? deliveryPointOrdersEx,
    String? message
  }) {
    return DeliveryPointState(
      status: status ?? this.status,
      deliveryPointEx: deliveryPointEx ?? this.deliveryPointEx,
      deliveryPointOrdersEx: deliveryPointOrdersEx ?? this.deliveryPointOrdersEx,
      message: message ?? this.message
    );
  }
}
