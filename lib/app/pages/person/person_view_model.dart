part of 'person_page.dart';

class PersonViewModel extends PageViewModel<PersonState, PersonStateStatus> {
  static const String _kManifestRepoUrl = 'https://unact.github.io/mobile_apps/delman';
  static const String _kAppRepoUrl = 'https://github.com/Unact/delman';

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
    String version = state.user!.version;
    String androidUpdateUrl = '$_kAppRepoUrl/releases/download/$version/app-release.apk';
    String iosUpdateUrl = 'itms-services://?action=download-manifest&url=$_kManifestRepoUrl/manifest.plist';
    String url = Platform.isIOS ? iosUpdateUrl : androidUpdateUrl;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      emit(state.copyWith(status: PersonStateStatus.failure, message: Strings.genericErrorMsg));
    }
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

      await Api(storage: app.storage).saveLogs(logs: logs);
      await FLog.clearLogs();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> _apiLogout() async {
    try {
      await Api(storage: app.storage).logout();
      await app.storage.clearData();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }
}
