import 'package:drift/drift.dart' show Value;
import 'package:u_app_utils/u_app_utils.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/repositories/base_repository.dart';
import '/app/services/delman_api.dart';

class DeliveriesRepository extends BaseRepository {
  DeliveriesRepository(AppDataStore dataStore, RenewApi api) : super(dataStore, api);

  Stream<List<DeliveryPointExResult>> watchExDeliveryPoints() {
    return dataStore.deliveriesDao.watchExDeliveryPoints();
  }

  Stream<List<ExDelivery>> watchExDeliveries() {
    return dataStore.deliveriesDao.watchExDeliveries();
  }

  Stream<List<DeliveryPointOrderExResult>> watchExDeliveryPointOrders() {
    return dataStore.deliveriesDao.watchExDeliveryPointOrders();
  }

  Future<void> closeDelivery() async {
    try {
      await api.closeDelivery();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> arriveAtDeliveryPoint({
    required DeliveryPointExResult deliveryPointEx,
    required DateTime factArrival,
    required Location location
  }) async {
    try {
      await api.arriveAtDeliveryPoint(
        deliveryPointId: deliveryPointEx.dp.id,
        factArrival: factArrival,
        location: location
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await dataStore.deliveriesDao.updateDeliveryPoint(
      deliveryPointEx.dp.id,
      DeliveryPointsCompanion(factArrival: Value(factArrival))
    );
  }

  Future<void> cancelOrder({
    required DeliveryPointOrderExResult deliveryPointOrderEx,
    required Location location
  }) async {
    try {
      await api.cancelOrder(
        deliveryPointOrderId: deliveryPointOrderEx.dpo.id,
        location: location
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await dataStore.deliveriesDao.updateDeliveryPointOrder(
      deliveryPointOrderEx.dpo.id,
      const DeliveryPointOrdersCompanion(canceled: Value(true), finished: Value(true))
    );
    await _departFromDeliveryPoint(deliveryPointOrderEx);
  }

  Future<void> confirmOrderFacts({
    required DeliveryPointOrderExResult deliveryPointOrderEx,
    required List<OrderLine> orderLines
  }) async {
    try {
      await api.confirmOrderFacts(
        deliveryPointOrderId: deliveryPointOrderEx.dpo.id,
        orderLines: orderLines.map((e) => {'id': e.id, 'factAmount': e.factAmount}).toList(),
      );

      await dataStore.ordersDao.updateOrder(
        deliveryPointOrderEx.o.id,
        const OrdersCompanion(factsConfirmed: Value(true))
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> confirmOrder({
    required DeliveryPointOrderExResult deliveryPointOrderEx,
    required bool isPickup,
    required User user,
    required Location location
  }) async {
    try {
      await api.confirmOrder(
        deliveryPointOrderId: deliveryPointOrderEx.dpo.id,
        location: location
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await dataStore.ordersDao.updateOrder(
      deliveryPointOrderEx.o.id,
      OrdersCompanion(storageId: Value(isPickup ? user.storageId : null))
    );

    await dataStore.deliveriesDao.updateDeliveryPointOrder(
      deliveryPointOrderEx.dpo.id,
      const DeliveryPointOrdersCompanion(finished: Value(true))
    );

    await _departFromDeliveryPoint(deliveryPointOrderEx);
  }

  Future<void> addOrderInfo({
    required DeliveryPointOrderExResult deliveryPointOrderEx,
    required String comment
  }) async {
    try {
      await api.addOrderInfo(orderId: deliveryPointOrderEx.o.id, comment: comment);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await dataStore.ordersDao.insertOrderInfoLine(OrderInfoLinesCompanion(
      orderId: Value(deliveryPointOrderEx.o.id),
      comment: Value(comment),
      ts: Value(DateTime.now())
    ));
  }

  Future<void> _departFromDeliveryPoint(DeliveryPointOrderExResult deliveryPointOrderEx) async {
    final deliveryOrderPointsEx = (await dataStore.deliveriesDao.watchExDeliveryPointOrders().first)
      .where((el) => el.dpo.deliveryPointId == deliveryPointOrderEx.dpo.deliveryPointId);

    if (deliveryOrderPointsEx.any((e) => !e.dpo.finished)) return;

    await dataStore.deliveriesDao.updateDeliveryPoint(
      deliveryPointOrderEx.dpo.deliveryPointId,
      DeliveryPointsCompanion(factDeparture: Value(DateTime.now()))
    );
  }
}
