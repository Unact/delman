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
class OrdersDao extends DatabaseAccessor<AppStorage> with _$OrdersDaoMixin {
  OrdersDao(AppStorage db) : super(db);

  Future<List<OrderWithTransferResult>> getOrdersWithTransfer() async {
    return await orderWithTransfer().get();
  }

  Future<List<Order>> getOrdersInStorage(int storageId) async {
    return (select(orders)..where((tbl) => tbl.storageId.equals(storageId))).get();
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

  Future<void> updateOrder(int id, OrdersCompanion order) {
    return (update(orders)..where((t) => t.id.equals(id))).write(order);
  }

  Future<void> updateOrderLine(int id, OrderLinesCompanion orderLine) {
    return (update(orderLines)..where((t) => t.id.equals(id))).write(orderLine);
  }

  Future<Order?> getOrderByTrackingNumber(String trackingNumber) {
    return (select(orders)..where((tbl) => tbl.trackingNumber.equals(trackingNumber))).getSingleOrNull();
  }

  Future<Order> getOrderById(int id) {
    return (select(orders)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<List<OrderLine>> getOrderLines(int orderId) async {
    final query = select(orderLines)..where((tbl) => tbl.orderId.equals(orderId))..orderBy([
      (u) => OrderingTerm.asc(u.name)
    ]);

    return query.get();
  }

  Future<List<OrderInfoLine>> getOrderInfoLines(int orderId) async {
    final query = select(orderInfoLines)..where((tbl) => tbl.orderId.equals(orderId))..orderBy([
      (u) => OrderingTerm.asc(u.ts)
    ]);

    return query.get();
  }

  Future<int> insertOrderInfoLine(OrderInfoLinesCompanion orderInfoLine) async {
    return into(orderInfoLines).insert(orderInfoLine);
  }
}
