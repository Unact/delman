import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:meta/meta.dart';
import 'package:package_info/package_info.dart';

import 'package:delman/app/repositories/repositories.dart';
import 'package:delman/app/services/api.dart';
import 'package:delman/app/services/sentry.dart';
import 'package:delman/app/services/storage.dart';

class App {
  final Sentry sentry;
  final Api api;
  final bool isDebug;
  final String version;
  final String buildNumber;
  final AppDataRepository appDataRepo;
  final DeliveryPointRepository deliveryPointRepo;
  final DeliveryRepository deliveryRepo;
  final OrderLineRepository orderLineRepo;
  final OrderRepository orderRepo;
  final PaymentRepository paymentRepo;
  final UserRepository userRepo;

  App._({
    @required this.sentry,
    @required this.api,
    @required this.isDebug,
    @required this.version,
    @required this.buildNumber,
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
    Sentry sentry = Sentry.init(
      version: version,
      osVersion: osVersion,
      deviceModel: deviceModel,
      dsn: DotEnv().env['SENTRY_DSN'],
      userRepo: userRepo,
      capture: !isDebug
    );
    Api api = Api.init(repo: ApiDataRepository(storage: storage), version: version);

    FlutterError.onError = (FlutterErrorDetails details) async {
      if (isDebug) {
        FlutterError.dumpErrorToConsole(details);
      } else {
        Zone.current.handleUncaughtError(details.exception, details.stack);
      }
    };

    return App._(
      sentry: sentry,
      api: api,
      isDebug: isDebug,
      version: version,
      buildNumber: buildNumber,
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
    await sentry.captureException(error, stackTrace);
  }
}
