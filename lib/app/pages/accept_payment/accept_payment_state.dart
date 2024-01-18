part of 'accept_payment_page.dart';

enum AcceptPaymentStateStatus {
  initial,
  searchingForDevice,
  gettingCredentials,
  paymentAuthorization,
  waitingForPayment,
  paymentStarted,
  paymentFinished,
  requiredSignature,
  savingSignature,
  savingPayment,
  finished,
  failure
}

class AcceptPaymentState {
  AcceptPaymentState({
    this.status = AcceptPaymentStateStatus.initial,
    required this.deliveryPointOrderEx,
    required this.total,
    required this.cardPayment,
    this.location,
    this.canceled = false,
    this.isCancelable = true,
    this.isRequiredSignature = false,
    this.message = ''
  });

  final AcceptPaymentStateStatus status;
  final DeliveryPointOrderExResult deliveryPointOrderEx;
  final bool cardPayment;
  final double total;
  final Location? location;
  final bool canceled;
  final bool isCancelable;
  final bool isRequiredSignature;
  final String message;

  AcceptPaymentState copyWith({
    AcceptPaymentStateStatus? status,
    DeliveryPointOrderExResult? deliveryPointOrderEx,
    bool? cardPayment,
    double? total,
    Location? location,
    bool? canceled,
    bool? isCancelable,
    bool? isRequiredSignature,
    String? message
  }) {
    return AcceptPaymentState(
      status: status ?? this.status,
      deliveryPointOrderEx: deliveryPointOrderEx ?? this.deliveryPointOrderEx,
      cardPayment: cardPayment ?? this.cardPayment,
      total: total ?? this.total,
      location: location ?? this.location,
      canceled: canceled ?? this.canceled,
      isCancelable: isCancelable ?? this.isCancelable,
      isRequiredSignature: isRequiredSignature ?? this.isRequiredSignature,
      message: message ?? this.message
    );
  }
}
