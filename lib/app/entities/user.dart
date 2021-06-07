import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String? email;
  final String? courierName;
  final int? courierStorageId;
  final String? version;

  static const int kGuestId = 1;
  static const String kGuestUsername = 'guest';

  bool get isLogged => id != kGuestId;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.courierName,
    this.courierStorageId,
    this.version
  });

  @override
  List<Object> get props => [id, username];

  static User fromJson(dynamic json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      courierName: json['courierName'],
      courierStorageId: json['courierStorageId'],
      version: json['version']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'username': username,
      'email': email,
      'courierName': courierName,
      'courierStorageId': courierStorageId,
      'version': version
    };
  }

  @override
  String toString() => 'User { id: $id }';
}
