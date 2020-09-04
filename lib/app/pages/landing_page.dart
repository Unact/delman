import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:delman/app/pages/home_page.dart';
import 'package:delman/app/pages/login_page.dart';
import 'package:delman/app/view_models/home_view_model.dart';
import 'package:delman/app/view_models/landing_view_model.dart';
import 'package:delman/app/view_models/login_view_model.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LandingViewModel>(
      builder: (context, vm, _) {
        return vm.isLogged ?
          ChangeNotifierProvider<HomeViewModel>(
            create: (context) => HomeViewModel(context: context),
            child: HomePage(),
          ) :
          ChangeNotifierProvider<LoginViewModel>(
            create: (context) => LoginViewModel(context: context),
            child: LoginPage(),
          );
      }
    );
  }
}
