import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/app.dart';
import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/pages/landing_page.dart';
import 'package:delman/app/view_models/landing_view_model.dart';

void main() async {
  App app = await App.init();

  runZonedGuarded<Future<void>>(() async {
    runApp(
      MultiProvider(
        providers: [
          Provider<App>(create: (context) => app),
          ChangeNotifierProvider<AppState>(create: (context) => AppState(app: app)),
          ChangeNotifierProvider<LandingViewModel>(create: (context) => LandingViewModel(context: context))
        ],
        child: Consumer<AppState>(
          builder: (context, vm, _) => MaterialApp(
            title: Strings.ruAppName,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              platform: TargetPlatform.android,
              visualDensity: VisualDensity.adaptivePlatformDensity
            ),
            home: LandingPage(),
            locale: Locale('ru', 'RU'),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('en', 'US'),
              Locale('ru', 'RU'),
            ]
          )
        )
      )
    );
  }, (Object error, StackTrace stackTrace) {
    app.reportError(error, stackTrace);
  });
}
