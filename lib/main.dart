import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:u_app_utils/u_app_utils.dart';

import 'app/constants/strings.dart';
import 'app/data/database.dart';
import 'app/pages/landing/landing_page.dart';
import 'app/repositories/app_repository.dart';
import 'app/repositories/deliveries_repository.dart';
import 'app/repositories/order_storages_repository.dart';
import 'app/repositories/orders_repository.dart';
import 'app/repositories/payments_repository.dart';
import 'app/repositories/users_repository.dart';


void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();
  await PackageInfo.fromPlatform();

  bool isDebug = Misc.isDebug();
  RenewApi api = await RenewApi.init(appName: Strings.appName);
  AppDataStore dataStore = AppDataStore(logStatements: isDebug);
  AppRepository appRepository = AppRepository(dataStore, api);

  DeliveriesRepository deliveriesRepository = DeliveriesRepository(dataStore, api);
  OrderStoragesRepository orderStoragesRepository = OrderStoragesRepository(dataStore, api);
  OrdersRepository ordersRepository = OrdersRepository(dataStore, api);
  PaymentsRepository paymentsRepository = PaymentsRepository(dataStore, api);
  UsersRepository usersRepository = UsersRepository(dataStore, api);

  FlutterError.onError = (errorDetails) {
    Misc.logError(errorDetails.exception, errorDetails.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    Misc.logError(error, stack);
    return true;
  };

  Initialization.intializeFlogs(isDebug: isDebug);
  await Initialization.initializeSentry(
    dsn: const String.fromEnvironment('DELMAN_SENTRY_DSN'),
    isDebug: false,
    userGenerator: () async {
      User user = await usersRepository.getCurrentUser();

      return SentryUser(id: user.id.toString(), username: user.username, email: user.email);
    },
    appRunner: () => runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: appRepository),
          RepositoryProvider.value(value: deliveriesRepository),
          RepositoryProvider.value(value: orderStoragesRepository),
          RepositoryProvider.value(value: ordersRepository),
          RepositoryProvider.value(value: paymentsRepository),
          RepositoryProvider.value(value: usersRepository),
        ],
        child: MaterialApp(
          title: Strings.ruAppName,
          theme: FlexThemeData.light(
            scheme: FlexScheme.blue,
            subThemesData: const FlexSubThemesData(
              inputDecoratorBorderType: FlexInputBorderType.underline,
              inputDecoratorFocusedBorderWidth: 0,
              inputDecoratorBackgroundAlpha: 0,
              inputDecoratorFillColor: Colors.transparent,
              bottomSheetRadius: 0
            ),
            platform: TargetPlatform.android,
            visualDensity: VisualDensity.adaptivePlatformDensity
          ),
          home: LandingPage(),
          locale: const Locale('ru', 'RU'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ru', 'RU'),
          ]
        )
      )
    )
  );
}
