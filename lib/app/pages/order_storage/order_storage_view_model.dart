part of 'order_storage_page.dart';

class OrderStorageViewModel extends PageViewModel<OrderStorageState, OrderStorageStateStatus> {
  final OrdersRepository ordersRepository;
  final UsersRepository usersRepository;

  StreamSubscription<List<Order>>? ordersSubscription;
  StreamSubscription<User>? userSubscription;

  OrderStorageViewModel(
    this.ordersRepository,
    this.usersRepository,
    {
      required OrderStorage orderStorage
    }
  ) : super(OrderStorageState(orderStorage: orderStorage, confirmationCallback: () {}));

  @override
  OrderStorageStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    ordersSubscription = ordersRepository.watchOrders().listen((event) {
      emit(state.copyWith(
        status: OrderStorageStateStatus.dataLoaded,
        orders: event
      ));
    });
    userSubscription = usersRepository.watchUser().listen((event) {
      emit(state.copyWith(status: OrderStorageStateStatus.dataLoaded, user: event));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await ordersSubscription?.cancel();
    await userSubscription?.cancel();
  }

  Future<void> startQRScan() async {
    if (!await Permissions.hasCameraPermissions()) {
      emit(state.copyWith(
        status: OrderStorageStateStatus.failure,
        message: 'Для сканирования QR кода необходимо разрешить использование камеры'
      ));
      return;
    }

    emit(state.copyWith(status: OrderStorageStateStatus.startedQRScan));
  }

  Future<Order?> orderFromManualInput(String trackingNumber, String packageNumberStr) async {
    int packageNumber = int.tryParse(packageNumberStr) ?? 1;

    Order? order = await ordersRepository.findOrder(trackingNumber);

    if (order == null) {
      emit(state.copyWith(
        status: OrderStorageStateStatus.failure,
        message: 'Не удалось найти заказ'
      ));
      return null;
    }

    if (order.packages != packageNumber) {
      emit(state.copyWith(
        status: OrderStorageStateStatus.failure,
        message: 'Указанное кол-во мест не совпадает с кол-вом мест заказа'
      ));
      return null;
    }

    return order;
  }

  Future<void> tryMoveOrder(Order order) async {
    if (order.storageId == state.user!.storageId) {
      await transferOrder(order);
    } else {
      await tryAcceptOrder(order);
    }
  }

  Future<void> tryAcceptOrder(Order order) async {
    if (order.documentsReturn) {
      emit(state.copyWith(
        status: OrderStorageStateStatus.needUserConfirmation,
        message: 'Вы забрали документы?',
        confirmationCallback: (bool confirmed) async {
          if (!confirmed) {
            emit(state.copyWith(
              status: OrderStorageStateStatus.failure,
              message: 'Нельзя принять заказ без возврата документов'
            ));
            return;
          }

          await acceptOrder(order);
        }
      ));


      return;
    }

    await acceptOrder(order);
  }

  Future<void> acceptOrder(Order order) async {
    emit(state.copyWith(status: OrderStorageStateStatus.inProgress));

    try {
      await ordersRepository.acceptOrder(order, state.user!);
      emit(state.copyWith(status: OrderStorageStateStatus.accepted, message: 'Заказ успешно принят'));
    } on AppError catch(e) {
      emit(state.copyWith(status: OrderStorageStateStatus.failure, message: e.message));
    }
  }

  Future<void> transferOrder(Order order) async {
    emit(state.copyWith(status: OrderStorageStateStatus.inProgress));

    try {
      await ordersRepository.transferOrder(order, state.orderStorage);
      emit(state.copyWith(
        status: OrderStorageStateStatus.trasferred,
        message: 'Заказ успешно передан в ${state.orderStorage.name}'
      ));
    } on AppError catch(e) {
      emit(state.copyWith(status: OrderStorageStateStatus.failure, message: e.message));
    }
  }
}
