part of 'order_storage_page.dart';

abstract class OrderStorageState {
  const OrderStorageState();
}

class OrderStorageInitial extends OrderStorageState {}

class OrderStorageInProgress extends OrderStorageState {}

class OrderStorageStartedQRScan extends OrderStorageState {}

class OrderStorageAccepted extends OrderStorageState {
  final String message;

  const OrderStorageAccepted(this.message);
}

class OrderStorageFailure extends OrderStorageState {
  final String message;

  const OrderStorageFailure(this.message);
}

class OrderStorageNeedUserConfirmation extends OrderStorageState {
  final String message;
  final Function confirmationCallback;

  const OrderStorageNeedUserConfirmation(this.message, this.confirmationCallback);
}

class OrderStorageTransferred extends OrderStorageState {
  final String message;

  const OrderStorageTransferred(this.message);
}
