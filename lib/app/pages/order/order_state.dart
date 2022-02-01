part of 'order_page.dart';

enum OrderStateStatus {
  initial,
  dataLoaded
}

class OrderState {
  OrderState({
    this.status = OrderStateStatus.initial,
    required this.order,
    this.user,
    this.orderLines = const [],
    this.orderInfoLines = const [],
  });

  final User? user;
  final Order order;
  final OrderStateStatus status;
  final List<OrderLine> orderLines;
  final List<OrderInfoLine> orderInfoLines;

  bool get withCourier => order.storageId == user?.storageId;

  OrderState copyWith({
    OrderStateStatus? status,
    Order? order,
    User? user,
    List<OrderLine>? orderLines,
    List<OrderInfoLine>? orderInfoLines
  }) {
    return OrderState(
      status: status ?? this.status,
      user: user ?? this.user,
      order: order ?? this.order,
      orderInfoLines: orderInfoLines ?? this.orderInfoLines,
      orderLines: orderLines ?? this.orderLines
    );
  }
}
