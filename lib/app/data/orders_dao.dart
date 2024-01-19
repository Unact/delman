part of 'database.dart';

@DriftAccessor(
  tables: [Orders, OrderLines, OrderInfoLines, Users, DeliveryPointOrders],
  queries: {
    'orderWithTransfer': '''
      SELECT
        o.*,
        EXISTS(
          SELECT 1
          FROM users
          WHERE users.storage_id = o.storage_id
        ) AS own,
        EXISTS(
          SELECT 1
          FROM delivery_point_orders dpo
          WHERE dpo.order_id = o.id AND dpo.pickup = 0 AND dpo.finished = 0
        ) AS need_transfer
      FROM orders AS o
      LEFT JOIN order_storages AS os ON os.id = o.storage_id
    '''
  }
)
class OrdersDao extends DatabaseAccessor<AppDataStore> with _$OrdersDaoMixin {
  OrdersDao(AppDataStore db) : super(db);

  Stream<List<Order>> watchOrders() {
    return select(orders).watch();
  }

  Future<void> loadOrders(List<Order> orderList) async {
    await batch((batch) {
      batch.deleteWhere(orders, (row) => const Constant(true));
      batch.insertAll(orders, orderList);
    });
  }

  Future<void> loadOrderLines(List<OrderLine> orderLineList) async {
    await batch((batch) {
      batch.deleteWhere(orderLines, (row) => const Constant(true));
      batch.insertAll(orderLines, orderLineList);
    });
  }

  Future<void> loadOrderInfoLines(List<OrderInfoLine> orderInfoLineList) async {
    await batch((batch) {
      batch.deleteWhere(orderInfoLines, (row) => const Constant(true));
      batch.insertAll(orderInfoLines, orderInfoLineList);
    });
  }

  Future<void> insertOrder(OrdersCompanion order) async {
    await into(orders).insert(order, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateOrder(int id, OrdersCompanion order) {
    return (update(orders)..where((t) => t.id.equals(id))).write(order);
  }

  Future<void> insertOrderLine(OrderLinesCompanion orderLine) async {
    await into(orderLines).insert(orderLine, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateOrderLine(int id, OrderLinesCompanion orderLine) {
    return (update(orderLines)..where((t) => t.id.equals(id))).write(orderLine);
  }

  Future<Order?> getOrderByTrackingNumber(String trackingNumber) {
    return (select(orders)..where((tbl) => tbl.trackingNumber.equals(trackingNumber))).getSingleOrNull();
  }

  Stream<Order> watchOrderById(int id) {
    return (select(orders)..where((tbl) => tbl.id.equals(id))).watchSingle();
  }

  Stream<List<OrderLine>> watchOrderLines(int orderId) {
    final query = select(orderLines)..where((tbl) => tbl.orderId.equals(orderId))..orderBy([
      (u) => OrderingTerm.asc(u.name)
    ]);

    return query.watch();
  }

  Stream<List<OrderInfoLine>> watchOrderInfoLines(int orderId) {
    final query = select(orderInfoLines)..where((tbl) => tbl.orderId.equals(orderId))..orderBy([
      (u) => OrderingTerm.asc(u.ts)
    ]);

    return query.watch();
  }

  Future<int> insertOrderInfoLine(OrderInfoLinesCompanion orderInfoLine) async {
    return into(orderInfoLines).insert(orderInfoLine, mode: InsertMode.insertOrReplace);
  }
}
