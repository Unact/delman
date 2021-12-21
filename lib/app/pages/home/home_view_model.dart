part of 'home_page.dart';

class HomeViewModel extends PageViewModel<HomeState> {
  int _currentIndex = 0;

  HomeViewModel(BuildContext context) : super(context, HomeInitial());

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int currentIndex) {
    _currentIndex = currentIndex;
    emit(HomePageChanged());
  }
}
