part of 'order_page.dart';

class OrderViewModel extends PageViewModel<OrderState, OrderStateStatus> {
  final OrdersRepository ordersRepository;
  final UsersRepository usersRepository;

  StreamSubscription<Order>? orderSubscription;
  StreamSubscription<List<OrderLine>>? orderLinesSubscription;
  StreamSubscription<List<OrderInfoLine>>? orderInfoLinesSubscription;
  StreamSubscription<User>? userSubscription;

  OrderViewModel(
    this.ordersRepository,
    this.usersRepository,
    {
      required Order order
    }
  ) : super(OrderState(order: order));

  @override
  OrderStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    userSubscription = usersRepository.watchUser().listen((event) {
      emit(state.copyWith(status: OrderStateStatus.dataLoaded, user: event));
    });
    orderSubscription = ordersRepository.watchOrderById(state.order.id).listen((event) {
      emit(state.copyWith(status: OrderStateStatus.dataLoaded, order: event));
    });
    orderLinesSubscription = ordersRepository.watchOrderLines(state.order.id).listen((event) {
      emit(state.copyWith(status: OrderStateStatus.dataLoaded, orderLines: event));
    });
    orderInfoLinesSubscription = ordersRepository.watchOrderInfoLines(state.order.id).listen((event) {
      emit(state.copyWith(status: OrderStateStatus.dataLoaded, orderInfoLines: event));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await orderSubscription?.cancel();
    await orderLinesSubscription?.cancel();
    await orderInfoLinesSubscription?.cancel();
    await userSubscription?.cancel();
  }
}
