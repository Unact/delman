part of 'order_page.dart';

class OrderViewModel extends PageViewModel<OrderState> {
  Order order;
  late List<OrderInfo> orderInfoList = [];
  late List<OrderLine> orderLines = [];

  OrderViewModel(BuildContext context, {required this.order}) : super(context, OrderInitial()) {
    orderInfoList = appViewModel.orderInfoList.where((e) => e.orderId == order.id).toList();
    orderLines = appViewModel.orderLines.where((e) => e.orderId == order.id).toList();
  }

  List<OrderInfo> get sortedOrderInfoList => orderInfoList..sort((a, b) => b.ts.compareTo(a.ts));
  List<OrderLine> get sortedOrderLines => orderLines..sort((a, b) => a.name.compareTo(b.name));
  bool get withCourier => order.storageId == appViewModel.user.storageId;
}
