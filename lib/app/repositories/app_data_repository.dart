import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class AppDataRepository {
  final Storage storage;

  AppDataRepository({@required this.storage});

  AppData getAppData() {
    String data = storage.prefs.getString('appData');
    return data == null ? AppData() : AppData.fromJson(json.decode(data));
  }

  Future<void> setAppData(AppData appData) async {
    await storage.prefs.setString('appData', json.encode(appData.toJson()));
  }

  Future<void> resetAppData() async {
    await setAppData(AppData());
  }
}
