part of 'person_page.dart';

class PersonViewModel extends PageViewModel<PersonState, PersonStateStatus> {
  PersonViewModel(BuildContext context) : super(context, PersonState());

  @override
  PersonStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.users
  ]);

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: PersonStateStatus.dataLoaded,
      user: await app.storage.usersDao.getUser(),
      lastSyncTime: (await app.storage.getSetting()).lastSync,
      fullVersion: app.fullVersion,
      newVersionAvailable: await app.newVersionAvailable,
    ));
  }

  Future<void> apiLogout() async {
    emit(state.copyWith(status: PersonStateStatus.inProgress));

    try {
      await _apiLogout();
      emit(state.copyWith(status: PersonStateStatus.loggedOut));
    } on AppError catch(e) {
      emit(state.copyWith(status: PersonStateStatus.failure, message: e.message));
    }
  }

  Future<void> launchAppUpdate() async {
    Misc.launchAppUpdate(
      repoName: Strings.repoName,
      version: state.user!.version,
      onError: () => emit(state.copyWith(status: PersonStateStatus.failure, message: Strings.genericErrorMsg))
    );
  }

  Future<void> sendLogs() async {
    emit(state.copyWith(status: PersonStateStatus.inProgress));

    try {
      await _sendLogs();
      emit(state.copyWith(status: PersonStateStatus.logsSend, message: 'Информация успешно отправлена'));
    } on AppError catch(e) {
      emit(state.copyWith(status: PersonStateStatus.failure, message: e.message));
    }
  }

  Future<void> _sendLogs() async {
    try {
      List<Log> logs = await FLog.getAllLogsByFilter(filterType: FilterType.TODAY);

      await app.api.saveLogs(logs: logs);
      await FLog.clearLogs();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> _apiLogout() async {
    try {
      await app.api.logout();
      await app.storage.clearData();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await Misc.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }
}
