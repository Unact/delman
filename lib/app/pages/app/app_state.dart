part of 'app_page.dart';

abstract class AppState {
  const AppState();
}

class AppInitial extends AppState {}

class AppLoadData extends AppState {}

class AppClearData extends AppState {}

class AppUpdate extends AppState {}
