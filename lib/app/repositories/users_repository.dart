import 'package:rxdart/rxdart.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/constants/strings.dart';
import '/app/data/database.dart';
import '/app/entities/entities.dart';
import '/app/repositories/base_repository.dart';
import '/app/services/delman_api.dart';

class UsersRepository extends BaseRepository {
  UsersRepository(AppDataStore dataStore, RenewApi api) : super(dataStore, api);

  late final _loggedInController = BehaviorSubject<bool>.seeded(api.isLoggedIn);

  Stream<bool> get isLoggedIn => _loggedInController.stream;

  Stream<User> watchUser() {
    return dataStore.usersDao.watchUser();
  }

  Future<User> getCurrentUser() {
    return dataStore.usersDao.getCurrentUser();
  }

  Future<void> loadUserData() async {
    try {
      final userData = await api.getUserData();

      await dataStore.usersDao.loadUser(userData.toDatabaseEnt());
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> login(String url, String login, String password) async {
    try {
      await api.login(url: url, login: login, password: password);
      _loggedInController.add(api.isLoggedIn);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await loadUserData();
  }

  Future<void> logout() async {
    try {
      await api.logout();
      _loggedInController.add(api.isLoggedIn);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> resetPassword(String url, String login) async {
    try {
      await api.resetPassword(url: url, login: login);
      _loggedInController.add(api.isLoggedIn);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }
}
