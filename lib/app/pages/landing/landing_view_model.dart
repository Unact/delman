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
    emit(state.copyWith(user: await app.storage.usersDao.getUser()));
  }
}
