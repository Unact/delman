part of 'app_page.dart';

abstract class AppState {
  AppState();
}

class AppInitial extends AppState {}

class AppLoadData extends AppState {}

class AppClearData extends AppState {}

class AppUpdate extends AppState {}
