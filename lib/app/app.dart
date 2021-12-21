import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/repositories/repositories.dart';
import 'package:delman/app/services/api.dart';
import 'package:delman/app/services/storage.dart';

class App {
  final bool isDebug;
  final String version;
  final String buildNumber;
  final String osVersion;
  final String deviceModel;

  App._({
    required this.isDebug,
    required this.version,
    required this.buildNumber,
    required this.osVersion,
    required this.deviceModel,
  }) {
    _instance = this;
  }

  static App? _instance;
  static App? get instance => _instance;

  static Future<App> init() async {
    if (_instance != null) return _instance!;

    AndroidDeviceInfo androidDeviceInfo;
    IosDeviceInfo iosDeviceInfo;
    String osVersion;
    String deviceModel;
    bool isDebug = false;
    assert(isDebug = true);

    WidgetsFlutterBinding.ensureInitialized();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await FkUserAgent.init();

    if (Platform.isIOS) {
      iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
      osVersion = iosDeviceInfo.systemVersion ?? '';
      deviceModel = iosDeviceInfo.utsname.machine ?? '';
    } else {
      androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
      osVersion = androidDeviceInfo.version.release ?? '';
      deviceModel = (androidDeviceInfo.brand ?? '') + ' - ' + (androidDeviceInfo.model ?? '');
    }

    await Storage.init();
    await Api.init();
    await _initSentry(dsn: const String.fromEnvironment('DELMAN_SENTRY_DSN'), capture: !isDebug);
    _intFlogs(isDebug: isDebug);

    FLog.info(text: 'App Initialized');

    return App._(
      isDebug: isDebug,
      version: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
      osVersion: osVersion,
      deviceModel: deviceModel,
    );
  }

  Future<void> reportError(dynamic error, dynamic stackTrace) async {
    debugPrint(error);
    debugPrint(stackTrace);
    await Sentry.captureException(error, stackTrace: stackTrace);
  }

  static void _intFlogs({
    required bool isDebug
  }) {
    LogsConfig config = LogsConfig();

    // В прод режими логируем все
    config.activeLogLevel = isDebug ? LogLevel.INFO : LogLevel.ALL;
    config.formatType = FormatType.FORMAT_SQUARE;
    config.timestampFormat = TimestampFormat.TIME_FORMAT_FULL_3;

    FLog.applyConfigurations(config);
  }

  static Future<void> _initSentry({
    required String dsn,
    required bool capture
  }) async {
    if (!capture) return;

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.beforeSend = (SentryEvent event, {dynamic hint}) {
          User user = UserRepository(storage: Storage.instance!).getUser();

          return event.copyWith(user: SentryUser(
            id: user.id.toString(),
            username: user.username,
            email: user.email
          ));
        };
      },
    );
  }
}
