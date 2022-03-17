import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app/app.dart';
import 'app/constants/strings.dart';
import 'app/pages/landing/landing_page.dart';

void main() async {
  App app = await App.init();

  runZonedGuarded<Future<void>>(() async {
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
    app.reportError(error, stackTrace);
  });
}
