import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String? email;
  final String? name;
  final int? storageId;
  final String? version;

  static const int kGuestId = 1;
  static const String kGuestUsername = 'guest';

  bool get isLogged => id != kGuestId;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.name,
    this.storageId,
    this.version
  });

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    name,
    storageId,
    version,
  ];

  factory User.fromJson(dynamic json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      storageId: json['storageId'],
      version: json['version']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'storageId': storageId,
      'version': version
    };
  }

  @override
  String toString() => 'User { id: $id }';
}
