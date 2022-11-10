part of 'order_storage_page.dart';

enum OrderStorageStateStatus {
  initial,
  dataLoaded,
  inProgress,
  startedQRScan,
  accepted,
  failure,
  needUserConfirmation,
  trasferred
}

class OrderStorageState {
  OrderStorageState({
    this.status = OrderStorageStateStatus.initial,
    required this.orderStorage,
    this.user,
    this.message = '',
    required this.confirmationCallback,
    this.ordersInOwnStorage = const [],
    this.ordersInOrderStorage = const [],
  });

  final OrderStorage orderStorage;
  final OrderStorageStateStatus status;
  final String message;
  final Function confirmationCallback;
  final List<Order> ordersInOwnStorage;
  final List<Order> ordersInOrderStorage;
  final User? user;

  OrderStorageState copyWith({
    OrderStorageStateStatus? status,
    User? user,
    OrderStorage? orderStorage,
    List<Order>? ordersInOwnStorage,
    List<Order>? ordersInOrderStorage,
    String? message,
    Function? confirmationCallback
  }) {
    return OrderStorageState(
      status: status ?? this.status,
      user: user ?? this.user,
      orderStorage: orderStorage ?? this.orderStorage,
      ordersInOwnStorage: ordersInOwnStorage ?? this.ordersInOwnStorage,
      ordersInOrderStorage: ordersInOrderStorage ?? this.ordersInOrderStorage,
      message: message ?? this.message,
      confirmationCallback: confirmationCallback ?? this.confirmationCallback
    );
  }
}
