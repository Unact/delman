import 'package:flutter/material.dart';

import 'package:delman/app/entities/user.dart';
import 'package:delman/app/view_models/base_view_model.dart';

class LandingViewModel extends BaseViewModel {
  LandingViewModel({@required BuildContext context}) : super(context: context);

  User get user => appState.user;
  bool get isLogged => user == null ? false : user.isLogged;
}
