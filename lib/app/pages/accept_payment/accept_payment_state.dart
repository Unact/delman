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
    this.position,
    this.canceled = false,
    this.isCancelable = true,
    this.isRequiredSignature = false,
    this.message = '',
    this.transaction
  });

  final AcceptPaymentStateStatus status;
  final DeliveryPointOrderExResult deliveryPointOrderEx;
  final bool cardPayment;
  final double total;
  final Position? position;
  final bool canceled;
  final bool isCancelable;
  final bool isRequiredSignature;
  final String message;
  final Map<String, dynamic>? transaction;

  AcceptPaymentState copyWith({
    AcceptPaymentStateStatus? status,
    DeliveryPointOrderExResult? deliveryPointOrderEx,
    bool? cardPayment,
    double? total,
    Position? position,
    bool? canceled,
    bool? isCancelable,
    bool? isRequiredSignature,
    String? message,
    Map<String, dynamic>? transaction
  }) {
    return AcceptPaymentState(
      status: status ?? this.status,
      deliveryPointOrderEx: deliveryPointOrderEx ?? this.deliveryPointOrderEx,
      cardPayment: cardPayment ?? this.cardPayment,
      total: total ?? this.total,
      position: position ?? this.position,
      canceled: canceled ?? this.canceled,
      isCancelable: isCancelable ?? this.isCancelable,
      isRequiredSignature: isRequiredSignature ?? this.isRequiredSignature,
      message: message ?? this.message,
      transaction: transaction ?? this.transaction
    );
  }
}
