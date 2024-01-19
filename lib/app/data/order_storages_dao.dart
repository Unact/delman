part of 'database.dart';

@DriftAccessor(tables: [OrderStorages, Users])
class OrderStoragesDao extends DatabaseAccessor<AppDataStore> with _$OrderStoragesDaoMixin {
  OrderStoragesDao(AppDataStore db) : super(db);

  Future<void> loadOrderStorages(List<OrderStorage> orderStorageList) async {
    await batch((batch) {
      batch.deleteWhere(orderStorages, (row) => const Constant(true));
      batch.insertAll(orderStorages, orderStorageList);
    });
  }

  Stream<List<OrderStorage>> watchForeignOrderStorages() {
    JoinedSelectStatement userStorageSelect = (selectOnly(users)..addColumns([users.storageId]));

    return (select(orderStorages)..where((tbl) => tbl.id.isNotInQuery(userStorageSelect))).watch();
  }

  Future<OrderStorage?> getOrderStorage(int id) async {
    return (select(orderStorages)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}
