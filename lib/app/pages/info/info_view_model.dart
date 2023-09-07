part of 'info_page.dart';

class InfoViewModel extends PageViewModel<InfoState, InfoStateStatus> {
  final HomeViewModel _homeViewModel;
  late final Timer _fetchDataTimer;

  InfoViewModel(BuildContext context) :
    _homeViewModel = context.read<HomeViewModel>(),
    super(context, InfoState()) {
      _fetchDataTimer = Timer.periodic(
        const Duration(minutes: 10),
        (_) => emit(state.copyWith(status: InfoStateStatus.startLoad))
      );
    }

  @override
  InfoStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => const TableUpdateQuery.any();

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();
    await _checkNeedRefresh();
  }

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: InfoStateStatus.dataLoaded,
      newVersionAvailable: await app.newVersionAvailable,
      cashPayments: await app.storage.paymentsDao.getCashPayments(),
      cardPayments: await app.storage.paymentsDao.getCardPayments(),
      orders: await app.storage.ordersDao.getOrdersWithTransfer(),
      deliveries: await app.storage.deliveriesDao.getExDeliveries(),
    ));
  }

  @override
  Future<void> close() async {
    _fetchDataTimer.cancel();
    await super.close();
  }

  Future<void> refresh([bool timer = false]) async {
    if (state.isBusy) return;

    try {
      emit(state.copyWith(status: InfoStateStatus.inLoadProgress));
      await _getData();

      emit(state.copyWith(status: InfoStateStatus.loadSuccess, message: 'Данные успешно обновлены'));
    } on AppError catch(e) {
      emit(state.copyWith(status: InfoStateStatus.loadFailure, message: e.message));
    }
  }

  Future<void> _checkNeedRefresh() async {
    if (state.isBusy) return;

    Setting setting = await app.storage.getSetting();

    if (setting.lastSync == null) {
      emit(state.copyWith(status: InfoStateStatus.startLoad));
      return;
    }

    DateTime lastAttempt = setting.lastSync!;
    DateTime time = DateTime.now();

    if (lastAttempt.year != time.year || lastAttempt.month != time.month || lastAttempt.day != time.day) {
      emit(state.copyWith(status: InfoStateStatus.startLoad));
    }
  }

  void changePage(int index) {
    _homeViewModel.setCurrentIndex(index);
  }

  Future<void> _closeDelivery() async {
    try {
      await app.api.closeDelivery();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await _getData();
  }

  Future<void> _getData() async {
    Location? location = await GeoLoc.getCurrentLocation();

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    await app.loadUserData();

    try {
      ApiData data = await app.api.getData();
      AppStorage storage = app.storage;
      Setting setting = await storage.getSetting();

      await storage.transaction(() async {
        await storage.deliveriesDao.loadDeliveries(data.deliveries.map((e) => e.toDatabaseEnt()).toList());
        await storage.deliveriesDao.loadDeliveryPoints(data.deliveryPoints.map((e) => e.toDatabaseEnt()).toList());
        await storage.ordersDao.loadOrders(data.orders.map((e) => e.toDatabaseEnt()).toList());
        await storage.ordersDao.loadOrderLines(data.orderLines.map((e) => e.toDatabaseEnt()).toList());
        await storage.ordersDao.loadOrderInfoLines(data.orderInfoList.map((e) => e.toDatabaseEnt()).toList());
        await storage.deliveriesDao.loadDeliveryPointOrders(
          data.deliveryPointOrders.map((e) => e.toDatabaseEnt()).toList()
        );
        await storage.paymentsDao.loadPayments(data.payments.map((e) => e.toDatabaseEnt()).toList());
        await storage.orderStoragesDao.loadOrderStorages(data.orderStorages.map((e) => e.toDatabaseEnt()).toList());
        await storage.updateSetting(setting.copyWith(lastSync: Value(DateTime.now())));
      });
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> closeDelivery() async {
    try {
      emit(state.copyWith(status: InfoStateStatus.inCloseProgress));
      await _closeDelivery();

      emit(state.copyWith(status: InfoStateStatus.closeSuccess, message: 'День успешно завершен'));
    } on AppError catch(e) {
      emit(state.copyWith(status: InfoStateStatus.closeFailure, message: e.message));
    }
  }
}
