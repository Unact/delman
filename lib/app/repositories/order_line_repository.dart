import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class OrderLineRepository {
  final Storage storage;
  final String _tableName = 'orderLines';

  OrderLineRepository({@required this.storage});

  Future<List<OrderLine>> getOrderLines() async {
    return (await storage.db.query(_tableName, orderBy: 'id')).map((e) => OrderLine.fromJson(e)).toList();
  }

  Future<void> addOrderLines(List<OrderLine> orderLines) async {
    Batch batch = storage.db.batch();
    await Future.wait(orderLines.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    await batch.commit(noResult: true);
  }

  Future<void> deleteOrderLines() async {
    await storage.db.delete(_tableName);
  }

  Future<void> reloadOrderLines(List<OrderLine> orderLines) async {
    await deleteOrderLines();
    await addOrderLines(orderLines);
  }

  Future<void> updateOrderLines(List<OrderLine> orderLines) async {
    Batch batch = storage.db.batch();
    await Future.wait(
      orderLines.map((e) async => await storage.db.update(_tableName, e.toJson(), where: 'id = ${e.id}'))
    );
    await batch.commit(noResult: true);
  }
}
