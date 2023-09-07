import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:u_app_utils/u_app_utils.dart';

import 'app/app.dart';
import 'app/constants/strings.dart';
import 'app/pages/landing/landing_page.dart';

void main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await App.init();

    runApp(MaterialApp(
      title: Strings.ruAppName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
    ));
  }, (Object error, StackTrace stackTrace) {
    Misc.reportError(error, stackTrace);
  });
}
