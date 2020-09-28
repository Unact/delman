import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/utils/format.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum PersonState {
  Initial,
  InProgress,
  LoggedOut,
  Failure
}

class PersonViewModel extends BaseViewModel {
  String _message;
  PersonState _state = PersonState.Initial;

  PersonViewModel({@required BuildContext context}) : super(context: context);

  PersonState get state => _state;
  String get message => _message;

  String get lastSyncTime {
    DateTime lastSyncTime = appState.appData.lastSyncTime;

    return lastSyncTime != null ? Format.dateTimeStr(lastSyncTime) : 'Не проводилось';
  }

  String get username => appState.user.username ?? '';
  String get courierName => appState.user.courierName ?? '';
  String get fullVersion => appState.fullVersion;
  bool get newVersionAvailable => appState.newVersionAvailable;

  Future<void> apiLogout() async {
    _setState(PersonState.InProgress);

    try {
      await appState.logout();
      _setState(PersonState.LoggedOut);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(PersonState.Failure);
    }
  }

  Future<void> launchAppUpdate() async {
    String androidUpdateUrl = "https://github.com/Unact/delman/releases/download/${appState.user.version}/app-release.apk";
    String iosUpdateUrl = 'itms-services://?action=download-manifest&url=https://unact.github.io/mobile_apps/delman/manifest.plist';
    String url = Platform.isIOS ? iosUpdateUrl : androidUpdateUrl;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _setMessage(Strings.genericErrorMsg);
      _setState(PersonState.Failure);
    }
  }

  void _setState(PersonState state) {
    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
