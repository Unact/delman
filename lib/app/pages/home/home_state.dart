part of 'home_page.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {}

class HomePageChanged extends HomeState {}
