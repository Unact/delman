part of 'login_page.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);
}

class LoginInProgress extends LoginState {}

class LoginPasswordSent extends LoginState {
  final String message;

  const LoginPasswordSent(this.message);
}

class LoginLoggedIn extends LoginState {}
