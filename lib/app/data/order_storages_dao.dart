part of 'database.dart';

@DriftAccessor(tables: [OrderStorages, Users])
class OrderStoragesDao extends DatabaseAccessor<AppStorage> with _$OrderStoragesDaoMixin {
  OrderStoragesDao(AppStorage db) : super(db);

  Future<void> loadOrderStorages(List<OrderStorage> orderStorageList) async {
    await batch((batch) {
      batch.deleteWhere(orderStorages, (row) => const Constant(true));
      batch.insertAll(orderStorages, orderStorageList);
    });
  }

  Future<List<OrderStorage>> getForeignOrderStorages() async {
    JoinedSelectStatement userStorageSelect = (selectOnly(users)..addColumns([users.storageId]));

    return (select(orderStorages)..where((tbl) => tbl.id.isNotInQuery(userStorageSelect))).get();
  }

  Future<OrderStorage?> getOrderStorage(int id) async {
    return (select(orderStorages)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}
