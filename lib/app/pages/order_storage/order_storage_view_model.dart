part of 'order_storage_page.dart';

class OrderStorageViewModel extends PageViewModel<OrderStorageState, OrderStorageStateStatus> {
  OrderStorageViewModel(
    BuildContext context,
    {
      required OrderStorage orderStorage
    }
  ) : super(context, OrderStorageState(orderStorage: orderStorage, confirmationCallback: () {}));

  @override
  OrderStorageStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.users,
    app.storage.orderStorages,
    app.storage.orders
  ]);

  @override
  Future<void> loadData() async {
    User user = await app.storage.usersDao.getUser();

    emit(state.copyWith(
      status: OrderStorageStateStatus.dataLoaded,
      user: user,
      orderStorage: await app.storage.orderStoragesDao.getOrderStorage(state.orderStorage.id),
      ordersInOwnStorage: await app.storage.ordersDao.getOrdersInStorage(user.storageId),
      ordersInOrderStorage: await app.storage.ordersDao.getOrdersInStorage(state.orderStorage.id)
    ));
  }

  Future<void> startQRScan() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isPermanentlyDenied || status.isDenied) {
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

    Order? order = await app.storage.ordersDao.getOrderByTrackingNumber(trackingNumber);

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
      await _acceptOrder(order);
      emit(state.copyWith(status: OrderStorageStateStatus.accepted, message: 'Заказ успешно принят'));
    } on AppError catch(e) {
      emit(state.copyWith(status: OrderStorageStateStatus.failure, message: e.message));
    }
  }

  Future<void> transferOrder(Order order) async {
    emit(state.copyWith(status: OrderStorageStateStatus.inProgress));

    try {
      await _transferOrder(order);
      emit(state.copyWith(
        status: OrderStorageStateStatus.trasferred,
        message: 'Заказ успешно передан в ${state.orderStorage.name}'
      ));
    } on AppError catch(e) {
      emit(state.copyWith(status: OrderStorageStateStatus.failure, message: e.message));
    }
  }

  Future<void> _acceptOrder(Order order) async {
    try {
      await app.api.acceptOrder(
        orderId: order.id
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.storage.ordersDao.updateOrder(
      order.id,
      OrdersCompanion(storageId: Value(state.user!.storageId))
    );
  }

  Future<void> _transferOrder(Order order) async {
    try {
      await app.api.transferOrder(
        orderId: order.id,
        orderStorageId: state.orderStorage.id
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.storage.ordersDao.updateOrder(
      order.id,
      const OrdersCompanion(storageId: Value(null))
    );
  }
}
