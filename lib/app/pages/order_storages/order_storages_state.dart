part of 'order_storages_page.dart';

enum OrderStoragesStateStatus {
  initial,
  dataLoaded,
  inProgress,
  startedQrScan,
  accepted,
  failure,
}

class OrderStoragesState {
  OrderStoragesState({
    this.status = OrderStoragesStateStatus.initial,
    this.orderStorages = const [],
    this.message = '',
    this.user,
  });

  final List<OrderStorage> orderStorages;
  final OrderStoragesStateStatus status;
  final String message;
  final User? user;

  OrderStoragesState copyWith({
    OrderStoragesStateStatus? status,
    List<OrderStorage>? orderStorages,
    String? message,
    User? user
  }) {
    return OrderStoragesState(
      status: status ?? this.status,
      orderStorages: orderStorages ?? this.orderStorages,
      message: message ?? this.message,
      user: user ?? this.user,
    );
  }
}
