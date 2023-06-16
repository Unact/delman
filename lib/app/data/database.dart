import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:delman/app/constants/strings.dart';

part 'schema.dart';
part 'database.g.dart';
part 'deliveries_dao.dart';
part 'order_storages_dao.dart';
part 'orders_dao.dart';
part 'payments_dao.dart';
part 'users_dao.dart';

@DriftDatabase(
  tables: [
    Deliveries,
    DeliveryPoints,
    DeliveryPointOrders,
    Orders,
    OrderLines,
    Payments,
    OrderStorages,
    OrderInfoLines,
    Users,
    Settings
  ],
  daos: [
    DeliveriesDao,
    OrderStoragesDao,
    OrdersDao,
    PaymentsDao,
    UsersDao,
  ]
)
class AppStorage extends _$AppStorage {
  static const int kSingleRecordId = 0;

  AppStorage({
    required bool logStatements
  }) : super(_openConnection(logStatements));

  Future<void> clearData() async {
    await transaction(() async {
      await _clearData();
      await _populateData();
    });
  }

  Future<void> _clearData() async {
    await batch((batch) {
      batch.deleteWhere(users, (row) => const Constant(true));
      batch.deleteWhere(settings, (row) => const Constant(true));
      batch.deleteWhere(orderInfoLines, (row) => const Constant(true));
      batch.deleteWhere(orderLines, (row) => const Constant(true));
      batch.deleteWhere(deliveryPointOrders, (row) => const Constant(true));
      batch.deleteWhere(deliveryPoints, (row) => const Constant(true));
      batch.deleteWhere(deliveries, (row) => const Constant(true));
      batch.deleteWhere(payments, (row) => const Constant(true));
      batch.deleteWhere(orders, (row) => const Constant(true));
      batch.deleteWhere(orderStorages, (row) => const Constant(true));
    });
  }

  Future<void> _populateData() async {
    await batch((batch) {
      batch.insert(users, User(
        id: UsersDao.kGuestId,
        username: UsersDao.kGuestUsername,
        email: '',
        name: '',
        storageId: 0,
        storageQR: '',
        version: '0.0.0'
      ));
      batch.insert(settings, Setting(
        id: kSingleRecordId
      ));
    });
  }

  Future<Setting> getSetting() async {
    return await (select(settings).getSingle());
  }

  Future<int> updateSetting(Setting setting) async {
    return into(settings).insertOnConflictUpdate(setting);
  }

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      for (final table in allTables) {
        await m.deleteTable(table.actualTableName);
        await m.createTable(table);
      }
    },
    beforeOpen: (details) async {
      if (details.hadUpgrade || details.wasCreated) await _populateData();
    },
  );
}

LazyDatabase _openConnection(bool logStatements) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, '${Strings.appName}.sqlite'));

    return NativeDatabase(file, logStatements: logStatements);
  });
}
