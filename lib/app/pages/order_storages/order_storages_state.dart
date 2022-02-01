part of 'order_storages_page.dart';

enum OrderStoragesStateStatus {
  initial,
  dataLoaded
}

class OrderStoragesState {
  OrderStoragesState({
    this.status = OrderStoragesStateStatus.initial,
    this.orderStorages = const []
  });

  final List<OrderStorage> orderStorages;
  final OrderStoragesStateStatus status;

  OrderStoragesState copyWith({
    OrderStoragesStateStatus? status,
    List<OrderStorage>? orderStorages
  }) {
    return OrderStoragesState(
      status: status ?? this.status,
      orderStorages: orderStorages ?? this.orderStorages
    );
  }
}
