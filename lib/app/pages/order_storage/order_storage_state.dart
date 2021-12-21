part of 'order_storage_page.dart';

abstract class OrderStorageState {
  OrderStorageState();
}

class OrderStorageInitial extends OrderStorageState {}

class OrderStorageInProgress extends OrderStorageState {}

class OrderStorageStartedQRScan extends OrderStorageState {}

class OrderStorageAccepted extends OrderStorageState {
  final String message;

  OrderStorageAccepted(this.message);
}

class OrderStorageFailure extends OrderStorageState {
  final String message;

  OrderStorageFailure(this.message);
}

class OrderStorageNeedUserConfirmation extends OrderStorageState {
  final String message;
  final Function confirmationCallback;

  OrderStorageNeedUserConfirmation(this.message, this.confirmationCallback);
}

class OrderStorageTransferred extends OrderStorageState {
  final String message;

  OrderStorageTransferred(this.message);
}
