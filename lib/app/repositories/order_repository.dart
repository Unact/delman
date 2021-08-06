import 'dart:async';

import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';


class OrderRepository {
  final Storage storage;
  final String _tableName = 'orders';

  OrderRepository({required this.storage});

  Future<List<Order>> getRecords() async {
    return (await storage.db.query(_tableName, orderBy: 'id')).map((e) => Order.fromJson(e)).toList();
  }

  Future<void> addRecords(List<Order> orders) async {
    Batch batch = storage.db.batch();
    await Future.wait(orders.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    await batch.commit(noResult: true);
  }

  Future<void> deleteRecords() async {
    await storage.db.delete(_tableName);
  }

  Future<void> reloadRecords(List<Order> orders) async {
    await deleteRecords();
    await addRecords(orders);
  }

  Future<void> updateRecord(Order order) async {
    await storage.db.update(_tableName, order.toJson(), where: 'id = ${order.id}');
  }
}
