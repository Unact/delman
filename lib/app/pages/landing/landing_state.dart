part of 'landing_page.dart';

enum LandingStateStatus {
  initial,
  pageChanged,
}

class LandingState {
  LandingState({
    this.status = LandingStateStatus.initial,
    this.user
  });

  final User? user;
  final LandingStateStatus status;
  bool get isLogged => user != null && user!.id != UsersDao.kGuestId;

  LandingState copyWith({
    LandingStateStatus? status,
    User? user
  }) {
    return LandingState(
      status: status ?? this.status,
      user: user ?? this.user,
    );
  }
}
