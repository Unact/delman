import 'package:drift/drift.dart' show Value;
import 'package:u_app_utils/u_app_utils.dart';

import '/app/constants/strings.dart';
import '/app/entities/entities.dart';
import '/app/data/database.dart';
import '/app/repositories/base_repository.dart';
import '/app/services/delman_api.dart';

class OrdersRepository extends BaseRepository {
  OrdersRepository(AppDataStore dataStore, RenewApi api) : super(dataStore, api);

  Stream<List<Order>> watchOrders() {
    return dataStore.ordersDao.watchOrders();
  }

  Stream<Order> watchOrderById(int id) {
    return dataStore.ordersDao.watchOrderById(id);
  }

  Stream<List<OrderInfoLine>> watchOrderInfoLines(int orderId) {
    return dataStore.ordersDao.watchOrderInfoLines(orderId);
  }

  Stream<List<OrderLine>> watchOrderLines(int orderId) {
    return dataStore.ordersDao.watchOrderLines(orderId);
  }

  Future<void> updateOrderLine(OrderLine orderLine, {
    required int? factAmount
  }) async {
    await dataStore.ordersDao.updateOrderLine(
      orderLine.id,
      OrderLinesCompanion(factAmount: factAmount == null ? const Value.absent() : Value.ofNullable(factAmount))
    );
  }

  Future<void> takeNewOrder(Order order, User user) async {
    try {
      await api.takeNewOrder(orderId: order.id);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await dataStore.ordersDao.updateOrder(order.id, OrdersCompanion(storageId: Value(user.storageId)));
  }

  Future<Order?> findOrder(String trackingNumber) async {
    try {
      Order? order = await dataStore.ordersDao.getOrderByTrackingNumber(trackingNumber);
      if (order != null) return order;

      ApiFindOrderData? data = await api.findOrderData(trackingNumber: trackingNumber);

      if (data != null) {
        order = data.order.toDatabaseEnt();

        await dataStore.transaction(() async {
          await dataStore.ordersDao.insertOrder(order!.toCompanion(false));
          await Future.forEach<OrderLinesCompanion>(
            data.orderLines.map((e) =>e.toDatabaseEnt().toCompanion(false)),
            (e) => dataStore.ordersDao.insertOrderLine(e)
          );
          await Future.forEach<OrderInfoLinesCompanion>(
            data.orderInfoList.map((e) =>e.toDatabaseEnt().toCompanion(false)),
            (e) => dataStore.ordersDao.insertOrderInfoLine(e)
          );
        });

        return order;
      }

      return null;
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> acceptOrder(Order order, User user) async {
    try {
      await api.acceptOrder(
        orderId: order.id
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await dataStore.ordersDao.updateOrder(
      order.id,
      OrdersCompanion(storageId: Value(user.storageId))
    );
  }

  Future<void> transferOrder(Order order, OrderStorage orderStorage) async {
    try {
      await api.transferOrder(
        orderId: order.id,
        orderStorageId: orderStorage.id
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await dataStore.ordersDao.updateOrder(
      order.id,
      const OrdersCompanion(storageId: Value(null))
    );
  }
}
