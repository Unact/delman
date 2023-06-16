part of 'landing_page.dart';

class LandingViewModel extends PageViewModel<LandingState, LandingStateStatus> {
  LandingViewModel(BuildContext context) : super(context, LandingState());

  @override
  LandingStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.users
  ]);

  @override
  Future<void> loadData() async {
    bool isLoggedIn = app.api.isLoggedIn;

    emit(state.copyWith(
      status: LandingStateStatus.dataLoaded,
      isLoggedIn: isLoggedIn
    ));
  }
}
