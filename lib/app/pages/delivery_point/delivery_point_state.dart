part of 'delivery_point_page.dart';

abstract class DeliveryPointState {
  const DeliveryPointState();
}

class DeliveryPointInitial extends DeliveryPointState {}

class DeliveryPointOrderDataCopied extends DeliveryPointState {
  final String message;

  const DeliveryPointOrderDataCopied(this.message);
}

class DeliveryPointInProgress extends DeliveryPointState {}

class DeliveryPointArrivalSaved extends DeliveryPointState {
  final String message;

  const DeliveryPointArrivalSaved(this.message);
}

class DeliveryPointFailure extends DeliveryPointState {
  final String message;

  const DeliveryPointFailure(this.message);
}
