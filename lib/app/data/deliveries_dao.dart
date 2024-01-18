part of 'database.dart';

@DriftAccessor(
  tables: [Deliveries, DeliveryPoints, DeliveryPointOrders],
  queries: {
    'deliveryPointEx': '''
      SELECT
        dp.**,
        CAST(
          CASE WHEN dp.fact_arrival IS NULL THEN 1 ELSE 0 END AS BOOLEAN
        ) is_not_arrived,
        CAST(
          NOT EXISTS(
            SELECT 1
            FROM delivery_point_orders AS dpo
            JOIN orders AS o ON o.id = dpo.order_id
            WHERE
              dpo.delivery_point_id = dp.id AND
              dpo.finished = 0
          ) AS BOOLEAN
        ) is_finished,
        CAST(
          CASE
            WHEN
              (CASE WHEN dp.fact_arrival IS NULL THEN 1 ELSE 0 END = 1) AND
              NOT EXISTS(
                SELECT 1
                FROM delivery_point_orders AS dpo
                JOIN orders AS o ON o.id = dpo.order_id
                WHERE
                  dpo.delivery_point_id = dp.id AND
                  dpo.finished = 0
              )
            THEN 1
            WHEN
              (CASE WHEN dp.fact_arrival IS NULL THEN 1 ELSE 0 END = 0) AND
              NOT EXISTS(
                SELECT 1
                FROM delivery_point_orders AS dpo
                JOIN orders AS o ON o.id = dpo.order_id
                WHERE
                  dpo.delivery_point_id = dp.id AND
                  dpo.finished = 0
              )
            THEN NOT EXISTS(
                SELECT 1
                FROM delivery_point_orders AS dpo
                JOIN orders AS o ON o.id = dpo.order_id
                WHERE
                  dpo.pickup = 0 AND
                  dpo.delivery_point_id = dp.id AND
                  o.need_payment = 1
              )
            ELSE 0
          END AS BOOLEAN
        ) is_completed,
        (
          SELECT MAX(CASE dpo.pickup WHEN 1 THEN o.pickup_date_time_from ELSE o.delivery_date_time_from END)
          FROM delivery_point_orders dpo
          JOIN orders o ON o.id = dpo.order_id
          WHERE dpo.delivery_point_id = dp.id
        ) date_time_from,
        (
          SELECT MAX(CASE dpo.pickup WHEN 1 THEN o.pickup_date_time_to ELSE o.delivery_date_time_to END)
          FROM delivery_point_orders dpo
          JOIN orders o ON o.id = dpo.order_id
          WHERE dpo.delivery_point_id = dp.id
        ) date_time_to
      FROM deliveries AS d
      JOIN delivery_points AS dp ON dp.delivery_id = d.id
      ORDER BY d.delivery_date ASC, dp.seq ASC
    ''',
    'deliveryPointOrderEx': '''
      SELECT
        dpo.**,
        o.**
      FROM delivery_point_orders dpo
      JOIN orders o ON o.id = dpo.order_id
      ORDER BY o.tracking_number ASC
    '''
  }
)
class DeliveriesDao extends DatabaseAccessor<AppDataStore> with _$DeliveriesDaoMixin {
  DeliveriesDao(AppDataStore db) : super(db);

  Stream<List<ExDelivery>> watchExDeliveries() {
    final deliveriesQuery = (select(deliveries)..orderBy([(t) => OrderingTerm.asc(t.deliveryDate)])).watch();
    final exDeliveryPointsQuery = deliveryPointEx().watch();

    return Rx.combineLatest2(
      deliveriesQuery,
      exDeliveryPointsQuery,
      (deliveriesRes, exDeliveryPointsRes) {
        return deliveriesRes.map((Delivery delivery) {
          return ExDelivery(
            delivery: delivery,
            deliveryPoints: exDeliveryPointsRes.where((element) => element.dp.deliveryId == delivery.id).toList()
          );
        }).toList();
      }
    );
  }

  Stream<List<DeliveryPointExResult>> watchExDeliveryPoints() {
    return deliveryPointEx().watch();
  }

  Stream<List<DeliveryPointOrderExResult>> watchExDeliveryPointOrders() {
    return deliveryPointOrderEx().watch();
  }

  Future<DeliveryPointOrderExResult?> getExDeliveryPointOrder(int deliveryPointOrderId) async {
    return (await deliveryPointOrderEx().get()).firstWhereOrNull((el) => el.dpo.id == deliveryPointOrderId);
  }

  Future<void> loadDeliveries(List<Delivery> deliveryList) async {
    await batch((batch) {
      batch.deleteWhere(deliveries, (row) => const Constant(true));
      batch.insertAll(deliveries, deliveryList);
    });
  }

  Future<void> loadDeliveryPoints(List<DeliveryPoint> deliveryPointList) async {
    await batch((batch) {
      batch.deleteWhere(deliveryPoints, (row) => const Constant(true));
      batch.insertAll(deliveryPoints, deliveryPointList);
    });
  }

  Future<void> loadDeliveryPointOrders(List<DeliveryPointOrder> deliveryPointOrderList) async {
    await batch((batch) {
      batch.deleteWhere(deliveryPointOrders, (row) => const Constant(true));
      batch.insertAll(deliveryPointOrders, deliveryPointOrderList);
    });
  }

  Future<void> updateDeliveryPoint(int id, DeliveryPointsCompanion deliveryPoint) {
    return (update(deliveryPoints)..where((t) => t.id.equals(id))).write(deliveryPoint);
  }

  Future<void> updateDeliveryPointOrder(int id, DeliveryPointOrdersCompanion deliveryPointOrder) {
    return (update(deliveryPointOrders)..where((t) => t.id.equals(id))).write(deliveryPointOrder);
  }
}

class ExDelivery {
  ExDelivery({
    required this.delivery,
    required this.deliveryPoints
  });

  final Delivery delivery;
  final List<DeliveryPointExResult> deliveryPoints;
}
