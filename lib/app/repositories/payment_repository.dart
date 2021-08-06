import 'dart:async';

import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';


class PaymentRepository {
  final Storage storage;
  final String _tableName = 'payments';

  PaymentRepository({required this.storage});

  Future<List<Payment>> getRecords() async {
    return (await storage.db.query(_tableName, orderBy: 'id')).map((e) => Payment.fromJson(e)).toList();
  }

  Future<void> addRecords(List<Payment> payments) async {
    Batch batch = storage.db.batch();
    await Future.wait(payments.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    await batch.commit(noResult: true);
  }

  Future<void> deleteRecords() async {
    await storage.db.delete(_tableName);
  }

  Future<void> reloadRecords(List<Payment> payments) async {
    await deleteRecords();
    await addRecords(payments);
  }
}
