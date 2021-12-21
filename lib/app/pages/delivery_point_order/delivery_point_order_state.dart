part of 'delivery_point_order_page.dart';

abstract class DeliveryPointOrderState {
  DeliveryPointOrderState();
}

class DeliveryPointOrderInitial extends DeliveryPointOrderState {}

class DeliveryPointOrderFailure extends DeliveryPointOrderState {
  final String message;

  DeliveryPointOrderFailure(this.message);
}

class DeliveryPointOrderLineChanged extends DeliveryPointOrderState {}

class DeliveryPointOrderInProgress extends DeliveryPointOrderState {}

class DeliveryPointOrderPaymentStarted extends DeliveryPointOrderState {}

class DeliveryPointOrderConfirmed extends DeliveryPointOrderState {
  final String message;

  DeliveryPointOrderConfirmed(this.message);
}

class DeliveryPointOrderCanceled extends DeliveryPointOrderState {
  final String message;

  DeliveryPointOrderCanceled(this.message);
}

class DeliveryPointOrderCommentAdded extends DeliveryPointOrderState {
  final String message;

  DeliveryPointOrderCommentAdded(this.message);
}

class DeliveryPointOrderNeedUserConfirmation extends DeliveryPointOrderState {
  final String message;
  final Function confirmationCallback;

  DeliveryPointOrderNeedUserConfirmation(this.message, this.confirmationCallback);
}

class DeliveryPointOrderPaymentFinished extends DeliveryPointOrderState {
  final String message;

  DeliveryPointOrderPaymentFinished(this.message);
}
