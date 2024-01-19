import 'package:drift/drift.dart' show Value;
import 'package:geolocator/geolocator.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/repositories/base_repository.dart';
import '/app/services/delman_api.dart';

class PaymentsRepository extends BaseRepository {
  PaymentsRepository(AppDataStore dataStore, RenewApi api) : super(dataStore, api);

  Stream<List<ExPayment>> watchPaymentsWithDPO() {
    return dataStore.paymentsDao.watchPaymentsWithDPO();
  }

  Future<void> acceptPayment({
    required Map<dynamic, dynamic>? transaction,
    required double summ,
    required DeliveryPointOrderExResult deliveryPointOrderEx,
    required Position position
  }) async {
    Map<String, dynamic> location = {
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'altitude': position.altitude,
      'heading': position.heading,
      'speed': position.speed,
      'pointTs': position.timestamp.toIso8601String()
    };

    try {
      await api.acceptPayment(
        deliveryPointOrderId: deliveryPointOrderEx.dpo.id,
        summ: summ,
        transaction: transaction,
        location: location
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await dataStore.paymentsDao.insertPayment(PaymentsCompanion(
      summ: Value(summ),
      transactionId: Value(transaction?['id']),
      deliveryPointOrderId: Value(deliveryPointOrderEx.dpo.id)
    ));

    await dataStore.ordersDao.updateOrder(
      deliveryPointOrderEx.o.id,
      const OrdersCompanion(needPayment: Value(false))
    );
  }
}
