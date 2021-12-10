part of 'landing_page.dart';

class LandingViewModel extends PageViewModel<LandingState> {
  LandingViewModel(BuildContext context) : super(context, LandingInitial());

  User get user => appViewModel.user;
  bool get isLogged => user.isLogged;
}
