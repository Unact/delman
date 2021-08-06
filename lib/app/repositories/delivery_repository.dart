import 'dart:async';

import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class DeliveryRepository {
  final Storage storage;
  final String _tableName = 'deliveries';

  DeliveryRepository({required this.storage});

  Future<List<Delivery>> getRecords() async {
    return (await storage.db.query(_tableName, orderBy: 'id')).map((e) => Delivery.fromJson(e)).toList();
  }

  Future<void> addRecords(List<Delivery> deliveries) async {
    Batch batch = storage.db.batch();
    await Future.wait(deliveries.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    batch.commit(noResult: true);
  }

  Future<void> deleteRecords() async {
    await storage.db.delete(_tableName);
  }

  Future<void> reloadRecords(List<Delivery> deliveries) async {
    await deleteRecords();
    await addRecords(deliveries);
  }
}
