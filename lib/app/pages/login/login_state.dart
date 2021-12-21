part of 'login_page.dart';

abstract class LoginState {
  LoginState();
}

class LoginInitial extends LoginState {}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}

class LoginInProgress extends LoginState {}

class LoginPasswordSent extends LoginState {
  final String message;

  LoginPasswordSent(this.message);
}

class LoginLoggedIn extends LoginState {}
