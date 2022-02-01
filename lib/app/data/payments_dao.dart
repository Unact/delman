part of 'database.dart';

@DriftAccessor(
  tables: [Payments, Orders, DeliveryPointOrders],
  queries: {
    'paymentWithOrder': '''
      SELECT
        p.**,
        dpo.**,
        o.**
      FROM payments AS p
      JOIN delivery_point_orders dpo on dpo.id = p.delivery_point_order_id
      JOIN orders o on o.id = dpo.order_id
    '''
  }
)
class PaymentsDao extends DatabaseAccessor<AppStorage> with _$PaymentsDaoMixin {
  PaymentsDao(AppStorage db) : super(db);

  Future<List<ExPayment>> getPaymentsWithDPO() async {
    final exPaymentsWithOrder = await paymentWithOrder().get();

    return exPaymentsWithOrder.map((PaymentWithOrderResult payment) {
      return ExPayment(
        payment: payment.p,
        deliveryPointOrderEx: DeliveryPointOrderExResult(dpo: payment.dpo, o: payment.o)
      );
    }).toList();
  }

  Future<List<Payment>> getCardPayments() async {
    return (select(payments)
      ..where((p) => p.transactionId.isNotNull())
      ..orderBy([(t) => OrderingTerm.asc(t.id)])
    ).get();
  }

  Future<List<Payment>> getCashPayments() async {
    return (select(payments)
      ..where((p) => p.transactionId.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.id)])
    ).get();
  }

  Future<Payment?> getPaymentForDPO(int deliveryPointId) async {
    return (select(payments)..where((p) => p.deliveryPointOrderId.equals(deliveryPointId))).getSingleOrNull();
  }

  Future<void> loadPayments(List<Payment> paymentList) async {
    await batch((batch) {
      batch.deleteWhere(payments, (row) => const Constant(true));
      batch.insertAll(payments, paymentList);
    });
  }

  Future<int> insertPayment(PaymentsCompanion payment) async {
    return into(payments).insert(payment);
  }
}

class ExPayment {
  ExPayment({
    required this.payment,
    required this.deliveryPointOrderEx
  });

  final Payment payment;
  final DeliveryPointOrderExResult deliveryPointOrderEx;
}
