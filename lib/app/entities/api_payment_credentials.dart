part of 'entities.dart';

class ApiPaymentCredentials {
  final String login;
  final String password;

  const ApiPaymentCredentials({
    required this.login,
    required this.password,
  });

  factory ApiPaymentCredentials.fromJson(dynamic json) {
    return ApiPaymentCredentials(
      login: json['login'],
      password: json['password']
    );
  }
}
