import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:rxdart/rxdart.dart';

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
    Prefs
  ],
  daos: [
    DeliveriesDao,
    OrderStoragesDao,
    OrdersDao,
    PaymentsDao,
    UsersDao,
  ],
  queries: {
    'appInfo': '''
      SELECT
        prefs.*,
        (
          SELECT COUNT(*)
          FROM orders
          WHERE EXISTS(SELECT 1 FROM users WHERE users.storage_id = orders.storage_id)
        ) AS "own_orders",
        (
          SELECT COUNT(*)
          FROM orders
          WHERE EXISTS(
            SELECT 1
            FROM delivery_point_orders dpo
            WHERE dpo.order_id = orders.id AND dpo.pickup = 0 AND dpo.finished = 0
          )
        ) AS "need_transfer_orders",
        (SELECT COUNT(*) FROM payments WHERE transaction_id IS NULL) AS "cash_payments_total",
        (SELECT COUNT(*) FROM payments WHERE transaction_id IS NOT NULL) AS "card_payments_total",
        COALESCE((SELECT SUM(summ) FROM payments WHERE transaction_id IS NULL), 0) AS "cash_payments_sum",
        COALESCE((SELECT SUM(summ) FROM payments WHERE transaction_id IS NOT NULL), 0) AS "card_payments_sum"
      FROM prefs
    '''
  },
)

class AppDataStore extends _$AppDataStore {
  static const int kSingleRecordId = 0;

  AppDataStore({
    required bool logStatements
  }) : super(_openConnection(logStatements));

  Stream<AppInfoResult> watchAppInfo() {
    return appInfo().watchSingle();
  }

  Future<int> updatePref(PrefsCompanion pref) {
    return update(prefs).write(pref);
  }

  Future<void> clearData() async {
    await transaction(() async {
      await _clearData();
      await _populateData();
    });
  }

  Future<void> _clearData() async {
    await batch((batch) {
      for (var table in allTables) {
        batch.deleteWhere(table, (row) => const Constant(true));
      }
    });
  }

  Future<void> _populateData() async {
    await batch((batch) {
      batch.insert(users, const User(
        id: UsersDao.kGuestId,
        username: UsersDao.kGuestUsername,
        email: '',
        name: '',
        storageId: 0,
        storageQR: '',
        version: '0.0.0'
      ));
      batch.insert(prefs, const Pref());
    });
  }

  @override
  int get schemaVersion => 8;

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

extension UserX on User {
  Future<bool> get newVersionAvailable async {
    final currentVersion = (await PackageInfo.fromPlatform()).version;

    return Version.parse(version) > Version.parse(currentVersion);
  }
}
