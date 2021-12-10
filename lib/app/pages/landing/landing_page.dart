import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:delman/app/entities/user.dart';
import 'package:delman/app/pages/home/home_page.dart';
import 'package:delman/app/pages/login/login_page.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'landing_state.dart';
part 'landing_view_model.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LandingViewModel>(
      create: (context) => LandingViewModel(context),
      child: LandingView(),
    );
  }
}

class LandingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingViewModel, LandingState>(
      builder: (context, state) {
        LandingViewModel vm = context.read<LandingViewModel>();

        return vm.isLogged ? HomePage() : LoginPage();
      }
    );
  }
}
