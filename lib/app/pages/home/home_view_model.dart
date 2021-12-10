part of 'home_page.dart';

class HomeViewModel extends PageViewModel<HomeState> {
  int _currentIndex = 0;
  bool _isLoading = false;

  HomeViewModel(BuildContext context) : super(context, HomeInitial());

  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;

  void setCurrentIndex(int currentIndex) {
    _currentIndex = currentIndex;
    emit(HomePageChanged());
  }
}
