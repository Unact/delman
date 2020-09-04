import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String courierName;
  final String version;

  static const int kGuestId = 1;
  static const String kGuestUsername = 'guest';

  bool get isLogged => id != null && id != kGuestId;

  const User({this.id, this.username, this.email, this.courierName, this.version});

  @override
  List<Object> get props => [id, email, courierName];

  static User fromJson(dynamic json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      courierName: json['courierName'],
      version: json['version']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'username': username,
      'email': email,
      'courierName': courierName,
      'version': version
    };
  }

  @override
  String toString() => 'User { id: $id }';
}
