part of 'entities.dart';

class ApiUserData {
  final int id;
  final String username;
  final String email;
  final String name;
  final int storageId;
  final String storageQR;
  final String version;

  const ApiUserData({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.storageId,
    required this.storageQR,
    required this.version
  });

  factory ApiUserData.fromJson(dynamic json) {
    return ApiUserData(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      storageId: json['storageId'],
      storageQR: json['storageQR'],
      version: json['app']['version']
    );
  }

  User toDatabaseEnt() {
    return User(
      id: id,
      username: username,
      name: name,
      email: email,
      storageId: storageId,
      storageQR: storageQR,
      version: version
    );
  }
}
