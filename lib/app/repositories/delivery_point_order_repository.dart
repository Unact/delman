import 'dart:async';

import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class DeliveryPointOrderRepository {
  final Storage storage;
  final String _tableName = 'deliveryPointOrders';

  DeliveryPointOrderRepository({required this.storage});

  Future<List<DeliveryPointOrder>> getRecords() async {
    return (await storage.db.query(_tableName, orderBy: 'id')).map((e) => DeliveryPointOrder.fromJson(e)).toList();
  }

  Future<void> addRecords(List<DeliveryPointOrder> deliveryPointOrders) async {
    Batch batch = storage.db.batch();
    await Future.wait(deliveryPointOrders.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    await batch.commit(noResult: true);
  }

  Future<void> deleteRecords() async {
    await storage.db.delete(_tableName);
  }

  Future<void> reloadRecords(List<DeliveryPointOrder> deliveryPointOrders) async {
    await deleteRecords();
    await addRecords(deliveryPointOrders);
  }

  Future<void> updateRecord(DeliveryPointOrder deliveryPointOrder) async {
    await storage.db.update(_tableName, deliveryPointOrder.toJson(), where: 'id = ${deliveryPointOrder.id}');
  }
}
