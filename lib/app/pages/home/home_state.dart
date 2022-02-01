part of 'home_page.dart';

enum HomeStateStatus {
  initial,
  pageChanged,
}

class HomeState {
  HomeState({
    this.status = HomeStateStatus.initial,
    this.currentIndex = 0
  });

  final int currentIndex;
  final HomeStateStatus status;

  HomeState copyWith({
    HomeStateStatus? status,
    int? currentIndex
  }) {
    return HomeState(
      status: status ?? this.status,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
