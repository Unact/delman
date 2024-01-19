import 'package:u_app_utils/u_app_utils.dart';

import '/app/data/database.dart';
import '/app/repositories/base_repository.dart';

class OrderStoragesRepository extends BaseRepository {
  OrderStoragesRepository(AppDataStore dataStore, RenewApi api) : super(dataStore, api);

  Stream<List<OrderStorage>> watchForeignOrderStorages() {
    return dataStore.orderStoragesDao.watchForeignOrderStorages();
  }
}
