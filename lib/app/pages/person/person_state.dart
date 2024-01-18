part of 'person_page.dart';

enum PersonStateStatus {
  initial,
  dataLoaded,
  inProgress,
  loggedOut,
  logsSend,
  failure
}

class PersonState {
  PersonState({
    this.status = PersonStateStatus.initial,
    this.user,
    this.appInfo,
    this.message = '',
  });

  final String message;
  final AppInfoResult? appInfo;
  final User? user;
  final PersonStateStatus status;

  PersonState copyWith({
    PersonStateStatus? status,
    User? user,
    AppInfoResult? appInfo,
    String? message
  }) {
    return PersonState(
      status: status ?? this.status,
      user: user ?? this.user,
      appInfo: appInfo ?? this.appInfo,
      message: message ?? this.message,
    );
  }
}
