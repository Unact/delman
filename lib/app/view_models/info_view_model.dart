import 'dart:async';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/app_state.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';
import 'package:delman/app/view_models/home_view_model.dart';

enum InfoState {
  Initial,
  InCloseProgress,
  InLoadProgress,
  CloseSuccess,
  LoadSuccess,
  LoadFailure,
  CloseFailure,
  TimerInLoadProgress,
  TimerLoadSuccess,
  TimerLoadFailure
}

class InfoViewModel extends BaseViewModel {
  HomeViewModel _homeViewModel;
  InfoState _state = InfoState.Initial;
  String? _message;
  Timer? fetchDataTimer;

  InfoViewModel({required BuildContext context}) :
    _homeViewModel = Provider.of<HomeViewModel>(context, listen: false),
    super(context: context) {
      _startRefreshTimer();
    }

  bool get isBusy => [
    InfoState.InLoadProgress,
    InfoState.TimerInLoadProgress,
    InfoState.InCloseProgress
  ].indexOf(_state) != -1;

  bool get needRefresh {
    if (isBusy)
      return false;

    if (appState.appData.lastSyncTime == null)
      return true;

    DateTime lastAttempt = appState.appData.lastSyncTime!;
    DateTime time = DateTime.now();

    return lastAttempt.year != time.year || lastAttempt.month != time.month || lastAttempt.day != time.day;
  }

  InfoState get state => _state;
  String? get message => _message;

  String? get timerFailureMessage => _state == InfoState.TimerLoadFailure ? _message : null;
  bool get newVersionAvailable => appState.newVersionAvailable;
  List<Delivery> get deliveries => appState.deliveries..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
  int get deliveryPointsCnt => appState.deliveryPoints.length;
  int get deliveryPointsLeftCnt => appState.deliveryPoints.where((e) => !e.isFinished).length;
  int get ordersInOwnStorageCnt => appState.orders.where((e) => e.storageId == appState.user.storageId).length;
  int get ordersNotInOwnStorageCnt {
    List<int> orderIds = appState.deliveryPointOrders
      .where((e) => !e.isPickup && !e.isFinished)
      .map((e) => e.orderId).toList();

    return appState.orders.where((e) => e.storageId != appState.user.storageId && orderIds.contains(e.id)).length;
  }
  int get paymentsCnt => appState.payments.length;
  int get cashPaymentsCnt => appState.payments.where((e) => !e.isCard).toList().length;
  int get cardPaymentsCnt => appState.payments.where((e) => e.isCard).toList().length;
  double get paymentsSum =>
    appState.payments.fold(0, (prev, el) => prev + el.summ);
  double get cashPaymentsSum =>
    appState.payments.where((e) => !e.isCard).toList().fold(0, (prev, el) => prev + el.summ);
  double get cardPaymentsSum =>
    appState.payments.where((e) => e.isCard).toList().fold(0, (prev, el) => prev + el.summ);

  Future<void> refresh([bool timerCallback = false]) async {
    if (isBusy)
      return;

    try {
      _setState(timerCallback ? InfoState.TimerInLoadProgress : InfoState.InLoadProgress);
      await appState.getData();

      _setMessage('Данные успешно обновлены');
      _setState(timerCallback ? InfoState.TimerLoadSuccess : InfoState.LoadSuccess);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(timerCallback ? InfoState.TimerLoadFailure : InfoState.LoadFailure);
    }
  }

  void changePage(int index) {
    _homeViewModel.setCurrentIndex(index);
  }

  void _startRefreshTimer() {
    if (fetchDataTimer == null || !fetchDataTimer!.isActive) {
      fetchDataTimer = Timer.periodic(Duration(minutes: 10), (_) => refresh(true));
    }
  }

  void _stopRefreshTimer() {
    if (fetchDataTimer != null && fetchDataTimer!.isActive) {
      fetchDataTimer!.cancel();
    }
  }

  void _setState(InfoState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }

  Future<void> closeDelivery() async {
    try {
      _setState(InfoState.InCloseProgress);
      await appState.closeDelivery();

      _setMessage('День успешно завершен');
      _setState(InfoState.CloseSuccess);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(InfoState.CloseFailure);
    }
  }

  @override
  void dispose() {
    _stopRefreshTimer();
    super.dispose();
  }
}
