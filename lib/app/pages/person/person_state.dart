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
    this.lastSyncTime,
    this.fullVersion = '',
    this.newVersionAvailable = false,
    this.message = '',
  });

  final String message;
  final DateTime? lastSyncTime;
  final User? user;
  final String fullVersion;
  final bool newVersionAvailable;
  final PersonStateStatus status;

  PersonState copyWith({
    PersonStateStatus? status,
    User? user,
    DateTime? lastSyncTime,
    String? fullVersion,
    bool? newVersionAvailable,
    String? message
  }) {
    return PersonState(
      status: status ?? this.status,
      user: user ?? this.user,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      fullVersion: fullVersion ?? this.fullVersion,
      newVersionAvailable: newVersionAvailable ?? this.newVersionAvailable,
      message: message ?? this.message,
    );
  }
}
