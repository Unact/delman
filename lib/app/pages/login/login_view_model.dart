part of 'login_page.dart';

class LoginViewModel extends PageViewModel<LoginState, LoginStateStatus> {
  LoginViewModel(BuildContext context) : super(context, LoginState());

  @override
  LoginStateStatus get status => state.status;

  @override
  Future<void> loadData() async {
    emit(state.copyWith(fullVersion: app.fullVersion));
  }

  Future<void> apiLogin(String url, String login, String password) async {
    if (!state.optsEnabled) login = _formatLogin(login);

    if (password == Strings.optsPasswordKeyword && login == Strings.optsLoginKeyword) {
      emit(state.copyWith(
        status: LoginStateStatus.urlFieldActivated,
        login: '',
        password: '',
        optsEnabled: true
      ));

      return;
    }

    if (login == '') {
      emit(state.copyWith(status: LoginStateStatus.failure, message: 'Не заполнено поле с логином'));
      return;
    }

    if (password == '') {
      emit(state.copyWith(status: LoginStateStatus.failure, message: 'Не заполнено поле с паролем'));
      return;
    }

    emit(state.copyWith(
      login: login,
      password: password,
      url: url,
      status: LoginStateStatus.inProgress
    ));

    try {
      await _login(url, login, password);
      emit(state.copyWith(status: LoginStateStatus.loggedIn));
    } on AppError catch(e) {
      emit(state.copyWith(status: LoginStateStatus.failure, message: e.message));
    }
  }

  Future<void> getNewPassword(String url, String login) async {
    if (!state.optsEnabled) login = _formatLogin(login);

    if (login == '') {
      emit(state.copyWith(status: LoginStateStatus.failure, message: 'Не заполнено поле с логином'));
      return;
    }

    emit(state.copyWith(
      login: login,
      password: '',
      url: url,
      status: LoginStateStatus.inProgress
    ));

    try {
      await _resetPassword(url, login);
      emit(state.copyWith(status: LoginStateStatus.passwordSent, message: 'Пароль отправлен на почту'));
    } on AppError catch(e) {
      emit(state.copyWith(status: LoginStateStatus.failure, message: e.message));
    }
  }

  Future<void> _login(String url, String login, String password) async {
    try {
      await app.api.login(url: url, login: login, password: password);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.loadUserData();
  }

  Future<void> _resetPassword(String url, String login) async {
    try {
      await app.api.resetPassword(url: url, login: login);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  String _formatLogin(String login) {
    return login.replaceAll(RegExp(r'[+\s\(\)-]'), '').replaceFirst('7', '8');
  }
}
