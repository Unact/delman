import 'package:drift/drift.dart' show Value;
import 'package:f_logs/f_logs.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/repositories/base_repository.dart';
import '/app/services/delman_api.dart';

class AppRepository extends BaseRepository {
  AppRepository(AppDataStore dataStore, RenewApi api) : super(dataStore, api);

  Stream<AppInfoResult> watchAppInfo() {
    return dataStore.watchAppInfo();
  }

  Future<ApiPaymentCredentials> getApiPaymentCredentials() async {
    try {
      return await api.getPaymentCredentials();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> loadData() async {
    try {
      ApiData data = await api.loadData();

      await dataStore.transaction(() async {
        await dataStore.deliveriesDao.loadDeliveries(data.deliveries.map((e) => e.toDatabaseEnt()).toList());
        await dataStore.deliveriesDao.loadDeliveryPoints(data.deliveryPoints.map((e) => e.toDatabaseEnt()).toList());
        await dataStore.ordersDao.loadOrders(data.orders.map((e) => e.toDatabaseEnt()).toList());
        await dataStore.ordersDao.loadOrderLines(data.orderLines.map((e) => e.toDatabaseEnt()).toList());
        await dataStore.ordersDao.loadOrderInfoLines(data.orderInfoList.map((e) => e.toDatabaseEnt()).toList());
        await dataStore.deliveriesDao.loadDeliveryPointOrders(
          data.deliveryPointOrders.map((e) => e.toDatabaseEnt()).toList()
        );
        await dataStore.paymentsDao.loadPayments(data.payments.map((e) => e.toDatabaseEnt()).toList());
        await dataStore.orderStoragesDao.loadOrderStorages(data.orderStorages.map((e) => e.toDatabaseEnt()).toList());
        await dataStore.updatePref(PrefsCompanion(lastLoadTime: Value(DateTime.now())));
      });
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> sendLogs() async {
    try {
      List<Log> logs = await FLog.getAllLogsByFilter(filterType: FilterType.TODAY);

      await api.saveLogs(logs: logs);
      await FLog.clearLogs();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> clearData() async {
    await dataStore.clearData();
  }
}
