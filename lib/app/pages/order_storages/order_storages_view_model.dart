part of 'order_storages_page.dart';

class OrderStoragesViewModel extends PageViewModel<OrderStoragesState, OrderStoragesStateStatus> {
  final OrderStoragesRepository orderStoragesRepository;
  final OrdersRepository ordersRepository;
  final UsersRepository usersRepository;

  StreamSubscription<List<OrderStorage>>? orderStoragesSubscription;
  StreamSubscription<User>? userSubscription;

  OrderStoragesViewModel(
    this.orderStoragesRepository,
    this.ordersRepository,
    this.usersRepository
  ) : super(OrderStoragesState());

  @override
  OrderStoragesStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    orderStoragesSubscription = orderStoragesRepository.watchForeignOrderStorages().listen((event) {
      emit(state.copyWith(status: OrderStoragesStateStatus.dataLoaded, orderStorages: event));
    });
    userSubscription = usersRepository.watchUser().listen((event) {
      emit(state.copyWith(status: OrderStoragesStateStatus.dataLoaded, user: event));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await orderStoragesSubscription?.cancel();
    await userSubscription?.cancel();
  }

  Future<void> startQRScan() async {
    if (!await Permissions.hasCameraPermissions()) {
      emit(state.copyWith(
        status: OrderStoragesStateStatus.failure,
        message: 'Для сканирования QR кода необходимо разрешить использование камеры'
      ));
      return;
    }

    emit(state.copyWith(status: OrderStoragesStateStatus.startedQRScan));
  }

  Future<void> takeNewOrder(Order order) async {
    emit(state.copyWith(status: OrderStoragesStateStatus.inProgress));

    try {
      await ordersRepository.takeNewOrder(order, state.user!);
      emit(state.copyWith(status: OrderStoragesStateStatus.accepted, message: 'Заказ успешно принят'));
    } on AppError catch(e) {
      emit(state.copyWith(status: OrderStoragesStateStatus.failure, message: e.message));
    }
  }
}
