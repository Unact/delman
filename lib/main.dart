import 'dart:async';

import 'package:flutter/material.dart';

import 'package:delman/app/app.dart';
import 'package:delman/app/pages/app/app_page.dart';

void main() async {
  App app = await App.init();

  runZonedGuarded<Future<void>>(() async {
    runApp(AppPage(app: app));
  }, (Object error, StackTrace stackTrace) {
    app.reportError(error, stackTrace);
  });
}
