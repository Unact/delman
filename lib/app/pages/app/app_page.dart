import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:quiver/core.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:delman/app/app.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/landing/landing_page.dart';
import 'package:delman/app/repositories/repositories.dart';
import 'package:delman/app/services/api.dart';
import 'package:delman/app/services/storage.dart';
import 'package:delman/app/utils/geo_loc.dart';

part 'app_state.dart';
part 'app_view_model.dart';

class AppPage extends StatelessWidget {
  final App app;

  const AppPage({
    required this.app
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppViewModel>(
      create: (context) => AppViewModel(context, app: app),
      child: BlocBuilder<AppViewModel, AppState>(
        builder: (context, state) => MaterialApp(
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
    );
  }
}
