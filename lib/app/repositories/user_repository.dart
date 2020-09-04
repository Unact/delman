import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class UserRepository {
  final Storage storage;

  UserRepository({@required this.storage});

  static const User kGuestUser = User(id: User.kGuestId, username: User.kGuestUsername);

  User getUser() {
    String data = storage.prefs.getString('user');
    return data == null ? kGuestUser : User.fromJson(json.decode(data));
  }

  Future<void> setUser(User user) async {
    await storage.prefs.setString('user', json.encode(user.toJson()));
  }

  Future<User> resetUser() async {
    await setUser(kGuestUser);

    return kGuestUser;
  }
}
