part of 'point_address_page.dart';

abstract class PointAddressState {
  PointAddressState();
}

class PointAddressInitial extends PointAddressState {}

class PointAddressSelectionChange extends PointAddressState {}

class PointAddressFailure extends PointAddressState {
  final String message;

  PointAddressFailure(this.message);
}
