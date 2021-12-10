part of 'login_page.dart';

class LoginViewModel extends PageViewModel<LoginState> {
  String? _login;
  String? _password;
  late String _url;
  bool _showUrl = false;

  LoginViewModel(BuildContext context) : super(context, LoginInitial()) {
    String debugUrl = Platform.isIOS ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
    String baseUrl = appViewModel.app.isDebug ? debugUrl : 'https://data.unact.ru';

    _url = '$baseUrl/api/';
  }

  String get fullVersion => appViewModel.fullVersion;

  String? get login => _login;
  String? get password => _password;
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
      emit(LoginInitial());

      return;
    }

    if (_login == null || _login == '') {
      emit(LoginFailure('Не заполнено поле с логином'));
      return;
    }

    if (_password == null || _password == '') {
      emit(LoginFailure('Не заполнено поле с паролем'));
      return;
    }

    emit(LoginInProgress());

    try {
      await appViewModel.login(_url, _login!, _password!);
      emit(LoginLoggedIn());
    } on AppError catch(e) {
      emit(LoginFailure(e.message));
    }
  }

  Future<void> getNewPassword() async {
    if (_login == null || _login == '') {
      emit(LoginFailure('Не заполнено поле с логином'));

      return;
    }

    emit(LoginInProgress());

    try {
      await appViewModel.resetPassword(url, login!);
      emit(LoginPasswordSent('Пароль отправлен на почту'));
    } on AppError catch(e) {
      emit(LoginFailure(e.message));
    }
  }
}
