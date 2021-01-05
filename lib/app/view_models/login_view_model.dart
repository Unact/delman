import 'dart:io';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum LoginState {
  Initial,
  InProgress,
  PasswordSent,
  LoggedIn,
  Failure
}

class LoginViewModel extends BaseViewModel {
  LoginState _state = LoginState.Initial;
  String _message;
  String _login;
  String _password;
  String _url;
  bool _showUrl = false;

  LoginViewModel({@required BuildContext context}) : super(context: context) {
    String debugUrl = Platform.isIOS ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
    String baseUrl = app.isDebug ? debugUrl : 'https://data.unact.ru';

    _url = '$baseUrl/api/';
  }

  LoginState get state => _state;
  String get message => _message;
  String get fullVersion => appState.fullVersion;

  String get login => _login;
  String get password => _password;
  String get url => _url;
  bool get showUrl => _showUrl;

  void setLogin(String login) {
    _login = login;

    FLog.debug(text: login);
  }

  void setPassword(String password) {
    _password = password;

    FLog.debug(text: password.replaceAll(new RegExp('.'), '*'));
  }

  void setUrl(String url) {
    _url = url;

    FLog.debug(text: url);
  }

  Future<void> apiLogin() async {
    if (_login == _password && _login == Strings.optsKeyword) {
      _showUrl = true;
      _login = null;
      _password = null;
      _setState(LoginState.Initial);

      return false;
    }

    _setState(LoginState.InProgress);

    try {
      await appState.login(_url, _login, _password);
      _setState(LoginState.LoggedIn);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(LoginState.Failure);
    }
  }

  Future<void> getNewPassword() async {
    if (_login == null || _login == '') {
      _setMessage('Не заполнено поле с логином');
      _setState(LoginState.Failure);

      return;
    }

    _setState(LoginState.InProgress);

    try {
      await appState.resetPassword(url, login);
      _setMessage('Пароль отправлен на почту');
      _setState(LoginState.PasswordSent);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(LoginState.Failure);
    }
  }

  void _setState(LoginState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
