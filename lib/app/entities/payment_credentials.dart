import 'package:equatable/equatable.dart';

class PaymentCredentials extends Equatable {
  final String login;
  final String password;

  const PaymentCredentials({
    required this.login,
    required this.password,
  });

  @override
  List<Object?> get props => [
    login,
    password
  ];

  factory PaymentCredentials.fromJson(dynamic json) {
    return PaymentCredentials(
      login: json['login'],
      password: json['password']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'login': login,
      'password': password
    };
  }

  @override
  String toString() => 'PaymentCredentials { login: $login }';
}
