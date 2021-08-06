import 'dart:async';

import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class OrderStorageRepository {
  final Storage storage;
  final String _tableName = 'orderStorages';

  OrderStorageRepository({required this.storage});

  Future<List<OrderStorage>> getRecords() async {
    return (await storage.db.query(_tableName, orderBy: 'id')).map((e) => OrderStorage.fromJson(e)).toList();
  }

  Future<void> addRecords(List<OrderStorage> orderStorages) async {
    Batch batch = storage.db.batch();
    await Future.wait(orderStorages.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    await batch.commit(noResult: true);
  }

  Future<void> deleteRecords() async {
    await storage.db.delete(_tableName);
  }

  Future<void> reloadRecords(List<OrderStorage> orderStorages) async {
    await deleteRecords();
    await addRecords(orderStorages);
  }
}
