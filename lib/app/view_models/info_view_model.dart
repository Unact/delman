import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/geo_loc.dart';
import 'package:delman/app/view_models/base_view_model.dart';
import 'package:delman/app/view_models/home_view_model.dart';

enum InfoState {
  Initial,
  InProgress,
  DataLoaded,
  Failure
}

class InfoViewModel extends BaseViewModel {
  HomeViewModel _homeViewModel;
  InfoState _state = InfoState.Initial;
  String _message;

  InfoViewModel({@required BuildContext context}) : super(context: context) {
    _homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
  }

  bool get needRefresh {
    if (_state == InfoState.InProgress)
      return false;

    if (appState.appData.lastSyncTime == null)
      return true;

    DateTime lastAttempt = appState.appData.lastSyncTime;
    DateTime time = DateTime.now();

    return lastAttempt.year != time.year || lastAttempt.month != time.month || lastAttempt.day != time.day;
  }

  InfoState get state => _state;
  String get message => _message;

  bool get newVersionAvailable => appState.newVersionAvailable;
  int get deliveryPointsCnt => appState.deliveryPoints.length;
  int get deliveryPointsLeftCnt => appState.deliveryPoints.where((e) => !e.isFinished).length;
  int get paymentsCnt => appState.payments.length;
  int get cashPaymentsCnt => appState.payments.where((e) => !e.isCard).toList().length;
  int get cardPaymentsCnt => appState.payments.where((e) => e.isCard).toList().length;

  Future<void> getData() async {
    _setState(InfoState.InProgress);

    Location location = await GeoLoc.getCurrentLocation();

    if (location == null) {
      _setMessage('Для работы с приложением необходимо разрешить определение местоположения');
      _setState(InfoState.Failure);

      return;
    }

    try {
      await appState.getData();

      _setMessage('Данные успешно обновлены');
      _setState(InfoState.DataLoaded);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(InfoState.Failure);
    }
  }

  void changePage(int index) {
    _homeViewModel.setCurrentIndex(index);
  }

  void _setState(InfoState state) {
    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
