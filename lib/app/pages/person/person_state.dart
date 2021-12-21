part of 'person_page.dart';

abstract class PersonState {
  PersonState();
}

class PersonInitial extends PersonState {}

class PersonInProgress extends PersonState {}

class PersonLoggedOut extends PersonState {}

class PersonLogsSent extends PersonState {
  final String message;

  PersonLogsSent(this.message);
}

class PersonFailure extends PersonState {
  final String message;

  PersonFailure(this.message);
}
