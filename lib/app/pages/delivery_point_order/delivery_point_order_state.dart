part of 'delivery_point_order_page.dart';

enum DeliveryPointOrderStateStatus {
  initial,
  dataLoaded,
  inProgress,
  paymentStarted,
  confirmed,
  canceled,
  commentAdded,
  needUserConfirmation,
  askPaymentCollection,
  paymentFinished,
  failure
}

class DeliveryPointOrderState {
  DeliveryPointOrderState({
    this.status = DeliveryPointOrderStateStatus.initial,
    required this.deliveryPointOrderEx,
    this.deliveryPointEx,
    this.orderInfoLines = const [],
    this.orderLines = const [],
    this.cardPayment = false,
    this.message = '',
    required this.confirmationCallback,
    this.user,
    this.payment
  });

  final DeliveryPointOrderStateStatus status;
  final DeliveryPointOrderExResult deliveryPointOrderEx;
  final DeliveryPointExResult? deliveryPointEx;
  final List<OrderInfoLine> orderInfoLines;
  final List<OrderLine> orderLines;
  final bool cardPayment;
  final String message;
  final Function confirmationCallback;
  final User? user;
  final Payment? payment;

  double get total => payment?.summ ?? orderLines.fold(0, (prev, el) => prev + (el.factAmount ?? 0) * el.price);
  bool get withCourier => deliveryPointOrderEx.o.storageId == user?.storageId;
  bool get isFinishable => !(deliveryPointOrderEx.dpo.finished || deliveryPointEx?.isInProgress == false);
  bool get needPayment => !deliveryPointOrderEx.dpo.pickup &&
    deliveryPointOrderEx.dpo.finished &&
    !deliveryPointOrderEx.dpo.canceled &&
    payment == null &&
    total != 0;

  DeliveryPointOrderState copyWith({
    DeliveryPointOrderStateStatus? status,
    DeliveryPointOrderExResult? deliveryPointOrderEx,
    DeliveryPointExResult? deliveryPointEx,
    List<OrderInfoLine>? orderInfoLines,
    List<OrderLine>? orderLines,
    bool? cardPayment,
    String? message,
    Function? confirmationCallback,
    User? user,
    Payment? payment
  }) {
    return DeliveryPointOrderState(
      status: status ?? this.status,
      deliveryPointOrderEx: deliveryPointOrderEx ?? this.deliveryPointOrderEx,
      deliveryPointEx: deliveryPointEx ?? this.deliveryPointEx,
      orderInfoLines: orderInfoLines ?? this.orderInfoLines,
      orderLines: orderLines ?? this.orderLines,
      cardPayment: cardPayment ?? this.cardPayment,
      message: message ?? this.message,
      confirmationCallback: confirmationCallback ?? this.confirmationCallback,
      user: user ?? this.user,
      payment: payment ?? this.payment
    );
  }
}
