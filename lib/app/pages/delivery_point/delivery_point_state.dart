part of 'delivery_point_page.dart';

abstract class DeliveryPointState {
  DeliveryPointState();
}

class DeliveryPointInitial extends DeliveryPointState {}

class DeliveryPointOrderDataCopied extends DeliveryPointState {
  final String message;

  DeliveryPointOrderDataCopied(this.message);
}

class DeliveryPointInProgress extends DeliveryPointState {}

class DeliveryPointArrivalSaved extends DeliveryPointState {
  final String message;

  DeliveryPointArrivalSaved(this.message);
}

class DeliveryPointFailure extends DeliveryPointState {
  final String message;

  DeliveryPointFailure(this.message);
}
