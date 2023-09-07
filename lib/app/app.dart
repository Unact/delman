import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:u_app_utils/u_app_utils.dart';

import 'constants/strings.dart';
import 'data/database.dart';
import 'entities/entities.dart';
import 'services/delman_api.dart';

class App {
  final String version;
  final String buildNumber;
  final AppStorage storage;
  final RenewApi api;

  App._({
    required this.version,
    required this.buildNumber,
    required this.storage,
    required this.api
  }) {
    _instance = this;
  }

  static App? _instance;

  static Future<App> init() async {
    if (_instance != null) return _instance!;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    bool isDebug = Misc.isDebug();
    AppStorage storage = AppStorage(logStatements: isDebug);

    await Initialization.initializeSentry(
      dsn: const String.fromEnvironment('DELMAN_SENTRY_DSN'),
      isDebug: isDebug,
      userGenerator: () async {
        User user = await storage.usersDao.getUser();

        return SentryUser(id: user.id.toString(), username: user.username, email: user.email);
      }
    );
    Initialization.intializeFlogs(isDebug: isDebug);

    return App._(
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      storage: storage,
      api: await RenewApi.init(appName: Strings.appName)
    );
  }

  Future<bool> get newVersionAvailable async {
    String remoteVersion = (await storage.usersDao.getUser()).version;

    return Version.parse(remoteVersion) > Version.parse(version);
  }

  String get fullVersion => '$version+$buildNumber';

  Future<void> loadUserData() async {
    try {
      ApiUserData userData = await api.getUserData();

      await storage.usersDao.loadUser(userData.toDatabaseEnt());
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }
}
