import 'dart:async';

import 'package:meta/meta.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/storage.dart';

class DeliveryPointRepository {
  final Storage storage;
  final String _tableName = 'deliveryPoints';

  DeliveryPointRepository({@required this.storage});

  Future<List<DeliveryPoint>> getDeliveryPoints() async {
    return (await storage.db.query(_tableName, orderBy: 'id')).map((e) => DeliveryPoint.fromJson(e)).toList();
  }

  Future<void> addDeliveryPoints(List<DeliveryPoint> deliveries) async {
    Batch batch = storage.db.batch();
    await Future.wait(deliveries.map((e) async => await storage.db.insert(_tableName, e.toJson())));
    await batch.commit(noResult: true);
  }

  Future<void> deleteDeliveryPoints() async {
    await storage.db.delete(_tableName);
  }

  Future<void> reloadDeliveryPoints(List<DeliveryPoint> deliveryPoints) async {
    await deleteDeliveryPoints();
    await addDeliveryPoints(deliveryPoints);
  }

  Future<void> updateDeliveryPoint(DeliveryPoint deliveryPoint) async {
    await storage.db.update(_tableName, deliveryPoint.toJson(), where: 'id = ${deliveryPoint.id}');
  }
}
