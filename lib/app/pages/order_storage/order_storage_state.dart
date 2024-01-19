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
    this.orders = const []
  });

  final OrderStorage orderStorage;
  final OrderStorageStateStatus status;
  final String message;
  final Function confirmationCallback;
  final List<Order> orders;
  final User? user;

  List<Order> get ordersInOwnStorage => orders.where((el) => el.storageId == user?.storageId).toList();
  List<Order> get ordersInOrderStorage =>  orders.where((el) => el.storageId == orderStorage.id).toList();

  OrderStorageState copyWith({
    OrderStorageStateStatus? status,
    User? user,
    OrderStorage? orderStorage,
    List<Order>? orders,
    String? message,
    Function? confirmationCallback
  }) {
    return OrderStorageState(
      status: status ?? this.status,
      user: user ?? this.user,
      orderStorage: orderStorage ?? this.orderStorage,
      orders: orders ?? this.orders,
      message: message ?? this.message,
      confirmationCallback: confirmationCallback ?? this.confirmationCallback
    );
  }
}
