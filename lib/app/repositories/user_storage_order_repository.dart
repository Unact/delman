import 'dart:async';

import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class UserStorageOrderRepository {
  final Storage storage;
  final String _tableName = 'userStorageOrders';

  UserStorageOrderRepository({required this.storage});

  Future<List<UserStorageOrder>> getUserStorageOrders() async {
    return (await storage.db.query(_tableName, orderBy: 'orderId')).map((e) => UserStorageOrder.fromJson(e)).toList();
  }

  Future<void> addUserStorageOrders(List<UserStorageOrder> storageOrders) async {
    Batch batch = storage.db.batch();
    await Future.wait(storageOrders.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    await batch.commit(noResult: true);
  }

  Future<void> addUserStorageOrder(UserStorageOrder storageOrder) async {
    await storage.db.insert(_tableName, storageOrder.toJson());
  }

  Future<void> deleteUserStorageOrders() async {
    await storage.db.delete(_tableName);
  }

  Future<void> deleteUserStorageOrder(UserStorageOrder storageOrder) async {
    await storage.db.delete(_tableName, where: 'orderId = ${storageOrder.orderId}');
  }

  Future<void> reloadUserStorageOrders(List<UserStorageOrder> storageOrders) async {
    await deleteUserStorageOrders();
    await addUserStorageOrders(storageOrders);
  }
}
