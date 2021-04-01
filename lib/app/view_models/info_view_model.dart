import 'dart:async';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';
import 'package:delman/app/view_models/home_view_model.dart';

enum InfoState {
  Initial,
  InProgress,
  DataLoaded,
  Failure,
  TimerInProgress,
  TimerDataLoaded,
  TimerFailure
}

class InfoViewModel extends BaseViewModel {
  HomeViewModel _homeViewModel;
  InfoState _state = InfoState.Initial;
  String _message;
  Timer fetchDataTimer;

  InfoViewModel({@required BuildContext context}) : super(context: context) {
    _homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
    _startRefreshTimer();
  }

  bool get isRefreshing => _state == InfoState.InProgress || _state == InfoState.TimerInProgress;

  bool get needRefresh {
    if (isRefreshing)
      return false;

    if (appState.appData.lastSyncTime == null)
      return true;

    DateTime lastAttempt = appState.appData.lastSyncTime;
    DateTime time = DateTime.now();

    return lastAttempt.year != time.year || lastAttempt.month != time.month || lastAttempt.day != time.day;
  }

  InfoState get state => _state;
  String get message => _message;

  String get timerFailureMessage => _state == InfoState.TimerFailure ? _message : null;
  bool get newVersionAvailable => appState.newVersionAvailable;
  int get deliveryPointsCnt => appState.deliveryPoints.length;
  int get deliveryPointsLeftCnt => appState.deliveryPoints.where((e) => !e.isFinished).length;
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
    if (isRefreshing)
      return;

    try {
      _setState(timerCallback ? InfoState.TimerInProgress : InfoState.InProgress);
      await appState.getData();

      _setMessage('Данные успешно обновлены');
      _setState(timerCallback ? InfoState.TimerDataLoaded : InfoState.DataLoaded);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(timerCallback ? InfoState.TimerFailure : InfoState.Failure);
    }
  }

  void changePage(int index) {
    _homeViewModel.setCurrentIndex(index);
  }

  void _startRefreshTimer() {
    if (fetchDataTimer == null || !fetchDataTimer.isActive) {
      fetchDataTimer = Timer.periodic(Duration(minutes: 10), (_) => refresh(true));
    }
  }

  void _stopRefreshTimer() {
    if (fetchDataTimer != null && fetchDataTimer.isActive) {
      fetchDataTimer.cancel();
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

  @override
  void dispose() {
    _stopRefreshTimer();
    super.dispose();
  }
}
