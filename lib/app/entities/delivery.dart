import 'package:equatable/equatable.dart';

class Delivery extends Equatable {
  final int id;
  final int active;

  const Delivery({this.id, this.active});

  bool get isActive => active == 1;

  @override
  List<Object> get props => [id, active];

  static Delivery fromJson(dynamic map) {
    return Delivery(
      id: map['id'],
      active: map['active']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'active': active
    };
  }

  @override
  String toString() => 'Delivery { id: $id }';
}
