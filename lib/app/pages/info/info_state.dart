part of 'info_page.dart';

abstract class InfoState {
  InfoState();
}

class InfoInitial extends InfoState {}

class InfoInCloseProgress extends InfoState {}

class InfoCloseSuccess extends InfoState {
  final String message;

  InfoCloseSuccess(this.message);
}

class InfoCloseFailure extends InfoState {
  final String message;

  InfoCloseFailure(this.message);
}

class InfoInLoadProgress extends InfoState {}

class InfoTimerInLoadProgress extends InfoState {}

class InfoLoadSuccess extends InfoState {
  final String message;

  InfoLoadSuccess(this.message);
}

class InfoTimerLoadSuccess extends InfoState {}

class InfoLoadFailure extends InfoState {
  final String message;

  InfoLoadFailure(this.message);
}

class InfoTimerLoadFailure extends InfoState {
  final String message;

  InfoTimerLoadFailure(this.message);
}
