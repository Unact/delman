import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry_flutter/sentry_flutter.dart' as sentryLib;

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/repositories/repositories.dart';
import 'package:delman/app/services/api.dart';
import 'package:delman/app/services/storage.dart';

class App {
  final Api api;
  final bool isDebug;
  final String version;
  final String buildNumber;
  final String osVersion;
  final String deviceModel;
  final AppDataRepository appDataRepo;
  final DeliveryPointRepository deliveryPointRepo;
  final DeliveryRepository deliveryRepo;
  final OrderLineRepository orderLineRepo;
  final OrderRepository orderRepo;
  final PaymentRepository paymentRepo;
  final UserRepository userRepo;

  App._({
    @required this.api,
    @required this.isDebug,
    @required this.version,
    @required this.buildNumber,
    @required this.osVersion,
    @required this.deviceModel,
    @required this.appDataRepo,
    @required this.deliveryPointRepo,
    @required this.deliveryRepo,
    @required this.orderLineRepo,
    @required this.orderRepo,
    @required this.paymentRepo,
    @required this.userRepo,
  }) {
    _instance = this;
  }

  static App _instance;
  static App get instance => _instance;

  static Future<App> init() async {
    if (_instance != null)
      return _instance;

    AndroidDeviceInfo androidDeviceInfo;
    IosDeviceInfo iosDeviceInfo;
    String osVersion;
    String deviceModel;
    bool isDebug = false;
    assert(isDebug = true);

    WidgetsFlutterBinding.ensureInitialized();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    await FlutterUserAgent.init();
    await DotEnv().load('.env');

    if (Platform.isIOS) {
      iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
      osVersion = iosDeviceInfo.systemVersion;
      deviceModel = iosDeviceInfo.utsname.machine;
    } else {
      androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
      osVersion = androidDeviceInfo.version.release;
      deviceModel = androidDeviceInfo.brand + ' - ' + androidDeviceInfo.model;
    }

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    Storage storage = await Storage.init();
    AppDataRepository appDataRepo = AppDataRepository(storage: storage);
    DeliveryPointRepository deliveryPointRepo = DeliveryPointRepository(storage: storage);
    DeliveryRepository deliveryRepo = DeliveryRepository(storage: storage);
    OrderRepository orderRepo = OrderRepository(storage: storage);
    OrderLineRepository orderLineRepo = OrderLineRepository(storage: storage);
    PaymentRepository paymentRepo = PaymentRepository(storage: storage);
    UserRepository userRepo = UserRepository(storage: storage);
    Api api = Api.init(repo: ApiDataRepository(storage: storage), version: version);

    await _initSentry(dsn: DotEnv().env['SENTRY_DSN'], userRepo: userRepo, capture: !isDebug);
    _intFlogs(isDebug: isDebug);

    FLog.info(text: 'App Initialized');

    return App._(
      api: api,
      isDebug: isDebug,
      version: version,
      buildNumber: buildNumber,
      osVersion: osVersion,
      deviceModel: deviceModel,
      appDataRepo: appDataRepo,
      deliveryPointRepo: deliveryPointRepo,
      deliveryRepo: deliveryRepo,
      orderLineRepo: orderLineRepo,
      orderRepo: orderRepo,
      paymentRepo: paymentRepo,
      userRepo: userRepo,
    );
  }

  Future<void> reportError(dynamic error, dynamic stackTrace) async {
    print(error);
    print(stackTrace);
    await sentryLib.Sentry.captureException(error, stackTrace: stackTrace);
  }

  static void _intFlogs({
    @required bool isDebug
  }) {
    LogsConfig config = LogsConfig();

    // В прод режими логируем все
    config.activeLogLevel = isDebug ? LogLevel.INFO : LogLevel.ALL;
    config.formatType = FormatType.FORMAT_SQUARE;
    config.timestampFormat = TimestampFormat.TIME_FORMAT_FULL_3;

    FLog.applyConfigurations(config);
  }

  static Future<void> _initSentry({
    @required UserRepository userRepo,
    @required String dsn,
    @required bool capture
  }) async {
    if (!capture)
      return;

    await sentryLib.SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.beforeSend = (sentryLib.SentryEvent event, {dynamic hint}) {
          User user = userRepo.getUser();

          return event.copyWith(user: sentryLib.User(
            id: user.id.toString(),
            username: user.username,
            email: user.email
          ));
        };
      },
    );
  }
}
