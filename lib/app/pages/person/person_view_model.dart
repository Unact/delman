part of 'person_page.dart';

class PersonViewModel extends PageViewModel<PersonState> {
  PersonViewModel(BuildContext context) : super(context, PersonInitial());

  String get lastSyncTime {
    DateTime? lastSyncTime = appViewModel.appData.lastSyncTime;

    return lastSyncTime != null ? Format.dateTimeStr(lastSyncTime) : 'Не проводилось';
  }

  String get username => appViewModel.user.username;
  String get name => appViewModel.user.name ?? '';
  String get fullVersion => appViewModel.fullVersion;
  bool get newVersionAvailable => appViewModel.newVersionAvailable;

  Future<void> apiLogout() async {
    emit(PersonInProgress());

    try {
      await appViewModel.logout();
      emit(PersonLoggedOut());
    } on AppError catch(e) {
      emit(PersonFailure(e.message));
    }
  }

  Future<void> launchAppUpdate() async {
    String androidUpdateUrl = "https://github.com/Unact/delman/releases/download/${appViewModel.user.version}/app-release.apk";
    String iosUpdateUrl = 'itms-services://?action=download-manifest&url=https://unact.github.io/mobile_apps/delman/manifest.plist';
    String url = Platform.isIOS ? iosUpdateUrl : androidUpdateUrl;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      emit(PersonFailure(Strings.genericErrorMsg));
    }
  }

  Future<void> sendLogs() async {
    emit(PersonInProgress());

    try {
      await appViewModel.sendLogs();
      emit(PersonLogsSent('Информация успешно отправлена'));
    } on AppError catch(e) {
      emit(PersonFailure(e.message));
    }
  }
}
