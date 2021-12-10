part of 'info_page.dart';

abstract class InfoState {
  const InfoState();
}

class InfoInitial extends InfoState {}

class InfoInCloseProgress extends InfoState {}

class InfoCloseSuccess extends InfoState {
  final String message;

  const InfoCloseSuccess(this.message);
}

class InfoCloseFailure extends InfoState {
  final String message;

  const InfoCloseFailure(this.message);
}

class InfoInLoadProgress extends InfoState {}

class InfoTimerInLoadProgress extends InfoState {}

class InfoLoadSuccess extends InfoState {
  final String message;

  const InfoLoadSuccess(this.message);
}

class InfoTimerLoadSuccess extends InfoState {}

class InfoLoadFailure extends InfoState {
  final String message;

  const InfoLoadFailure(this.message);
}

class InfoTimerLoadFailure extends InfoState {
  final String message;

  const InfoTimerLoadFailure(this.message);
}
