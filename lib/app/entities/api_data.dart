import 'package:equatable/equatable.dart';

class ApiData extends Equatable {
  final String? login;
  final String? url;
  final String? password;
  final String? token;

  const ApiData({
    this.login,
    this.password,
    this.url,

    this.token
  });

  @override
  List<Object?> get props => [
    login,
    url,
    password,
    token
  ];

  factory ApiData.fromJson(dynamic json) {
    return ApiData(
      login: json['login'],
      password: json['password'],
      token: json['token'],
      url: json['url']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'login': login,
      'password': password,
      'token': token,
      'url': url
    };
  }

  @override
  String toString() => 'AuthData { login: $login }';
}
