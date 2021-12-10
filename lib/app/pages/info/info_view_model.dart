part of 'info_page.dart';

class InfoViewModel extends PageViewModel<InfoState> {
  HomeViewModel _homeViewModel;
  Timer? fetchDataTimer;

  InfoViewModel(BuildContext context) :
    _homeViewModel = context.read<HomeViewModel>(),
    super(context, InfoInitial()) {
      _startRefreshTimer();
    }

  bool get isBusy => [
    InfoInLoadProgress,
    InfoTimerInLoadProgress,
    InfoInCloseProgress
  ].indexOf(state.runtimeType) != -1;

  bool get needRefresh {
    if (isBusy)
      return false;

    if (appViewModel.appData.lastSyncTime == null)
      return true;

    DateTime lastAttempt = appViewModel.appData.lastSyncTime!;
    DateTime time = DateTime.now();

    return lastAttempt.year != time.year || lastAttempt.month != time.month || lastAttempt.day != time.day;
  }

  bool get newVersionAvailable => appViewModel.newVersionAvailable;
  List<Delivery> get deliveries => appViewModel.deliveries..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
  int get deliveryPointsCnt => appViewModel.deliveryPoints.length;
  int get deliveryPointsLeftCnt => appViewModel.deliveryPoints.where((e) => !e.isFinished).length;
  int get ordersInOwnStorageCnt => appViewModel.orders.where((e) => e.storageId == appViewModel.user.storageId).length;
  int get ordersNotInOwnStorageCnt {
    List<int> orderIds = appViewModel.deliveryPointOrders
      .where((e) => !e.isPickup && !e.isFinished)
      .map((e) => e.orderId).toList();

    return appViewModel.orders.where((e) => e.storageId != appViewModel.user.storageId && orderIds.contains(e.id)).length;
  }
  int get paymentsCnt => appViewModel.payments.length;
  int get cashPaymentsCnt => appViewModel.payments.where((e) => !e.isCard).toList().length;
  int get cardPaymentsCnt => appViewModel.payments.where((e) => e.isCard).toList().length;
  double get paymentsSum =>
    appViewModel.payments.fold(0, (prev, el) => prev + el.summ);
  double get cashPaymentsSum =>
    appViewModel.payments.where((e) => !e.isCard).toList().fold(0, (prev, el) => prev + el.summ);
  double get cardPaymentsSum =>
    appViewModel.payments.where((e) => e.isCard).toList().fold(0, (prev, el) => prev + el.summ);

  Future<void> refresh([bool timerCallback = false]) async {
    if (isBusy)
      return;

    try {
      emit(timerCallback ? InfoTimerInLoadProgress() : InfoInLoadProgress());
      await appViewModel.getData();

      emit(timerCallback ? InfoTimerLoadSuccess() : InfoLoadSuccess('День успешно завершен'));
    } on AppError catch(e) {
      emit(timerCallback ? InfoTimerLoadFailure(e.message) : InfoLoadFailure(e.message));
    }
  }

  void changePage(int index) {
    _homeViewModel.setCurrentIndex(index);
  }

  void _startRefreshTimer() {
    if (fetchDataTimer == null || !fetchDataTimer!.isActive) {
      fetchDataTimer = Timer.periodic(Duration(minutes: 1), (_) => refresh(true));
    }
  }

  void _stopRefreshTimer() {
    if (fetchDataTimer != null && fetchDataTimer!.isActive) {
      fetchDataTimer!.cancel();
    }
  }

  Future<void> closeDelivery() async {
    try {
      emit(InfoInCloseProgress());
      await appViewModel.closeDelivery();

      emit(InfoCloseSuccess('Данные успешно обновлены'));
    } on AppError catch(e) {
      emit(InfoCloseFailure(e.message));
    }
  }

  @override
  Future<void> close() async {
    _stopRefreshTimer();

    await super.close();
  }
}
