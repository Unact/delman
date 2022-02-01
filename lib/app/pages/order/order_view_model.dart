part of 'order_page.dart';

class OrderViewModel extends PageViewModel<OrderState, OrderStateStatus> {
  OrderViewModel(
    BuildContext context,
    {
      required Order order
    }
  ) : super(context, OrderState(order: order));

  @override
  OrderStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.users,
    app.storage.orderLines,
    app.storage.orderInfoLines,
    app.storage.orders
  ]);

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: OrderStateStatus.dataLoaded,
      user: await app.storage.usersDao.getUser(),
      order: await app.storage.ordersDao.getOrderById(state.order.id),
      orderInfoLines: await app.storage.ordersDao.getOrderInfoLines(state.order.id),
      orderLines: await app.storage.ordersDao.getOrderLines(state.order.id),
    ));
  }
}
