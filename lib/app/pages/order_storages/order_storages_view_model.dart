part of 'order_storages_page.dart';

class OrderStoragesViewModel extends PageViewModel<OrderStoragesState, OrderStoragesStateStatus> {
  OrderStoragesViewModel(BuildContext context) : super(context, OrderStoragesState());

  @override
  OrderStoragesStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.users,
    app.storage.orderStorages,
    app.storage.orders
  ]);

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: OrderStoragesStateStatus.dataLoaded,
      user: await app.storage.usersDao.getUser(),
      orderStorages: await app.storage.orderStoragesDao.getForeignOrderStorages()
    ));
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
      await _takeNewOrder(order);
      emit(state.copyWith(status: OrderStoragesStateStatus.accepted, message: 'Заказ успешно принят'));
    } on AppError catch(e) {
      emit(state.copyWith(status: OrderStoragesStateStatus.failure, message: e.message));
    }
  }

  Future<void> _takeNewOrder(Order order) async {
    try {
      await app.api.takeNewOrder(orderId: order.id);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.storage.ordersDao.updateOrder(
      order.id,
      OrdersCompanion(storageId: Value(state.user!.storageId))
    );
  }
}
