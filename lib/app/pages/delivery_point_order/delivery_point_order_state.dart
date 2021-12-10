part of 'delivery_point_order_page.dart';

abstract class DeliveryPointOrderState {
  const DeliveryPointOrderState();
}

class DeliveryPointOrderInitial extends DeliveryPointOrderState {}

class DeliveryPointOrderFailure extends DeliveryPointOrderState {
  final String message;

  const DeliveryPointOrderFailure(this.message);
}

class DeliveryPointOrderLineChanged extends DeliveryPointOrderState {}

class DeliveryPointOrderInProgress extends DeliveryPointOrderState {}

class DeliveryPointOrderPaymentStarted extends DeliveryPointOrderState {}

class DeliveryPointOrderConfirmed extends DeliveryPointOrderState {
  final String message;

  const DeliveryPointOrderConfirmed(this.message);
}

class DeliveryPointOrderCanceled extends DeliveryPointOrderState {
  final String message;

  const DeliveryPointOrderCanceled(this.message);
}

class DeliveryPointOrderCommentAdded extends DeliveryPointOrderState {
  final String message;

  const DeliveryPointOrderCommentAdded(this.message);
}

class DeliveryPointOrderNeedUserConfirmation extends DeliveryPointOrderState {
  final String message;
  final Function confirmationCallback;

  const DeliveryPointOrderNeedUserConfirmation(this.message, this.confirmationCallback);
}

class DeliveryPointOrderPaymentFinished extends DeliveryPointOrderState {
  final String message;

  const DeliveryPointOrderPaymentFinished(this.message);
}
