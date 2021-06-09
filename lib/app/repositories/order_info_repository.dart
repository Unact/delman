import 'dart:async';

import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class OrderInfoRepository {
  final Storage storage;
  final String _tableName = 'orderInfo';

  OrderInfoRepository({required this.storage});

  Future<List<OrderInfo>> getOrderInfo() async {
    return (await storage.db.query(_tableName, orderBy: 'id')).map((e) => OrderInfo.fromJson(e)).toList();
  }

  Future<void> addOrderInfo(List<OrderInfo> orderInfoList) async {
    Batch batch = storage.db.batch();
    await Future.wait(orderInfoList.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    await batch.commit(noResult: true);
  }

  Future<void> deleteOrderInfo() async {
    await storage.db.delete(_tableName);
  }

  Future<void> reloadOrderInfo(List<OrderInfo> orderInfoList) async {
    await deleteOrderInfo();
    await addOrderInfo(orderInfoList);
  }

  Future<void> updateOrderInfo(List<OrderInfo> orderInfoList) async {
    Batch batch = storage.db.batch();
    await Future.wait(
      orderInfoList.map((e) async => await storage.db.update(_tableName, e.toJson(), where: 'id = ${e.id}'))
    );
    await batch.commit(noResult: true);
  }
}
