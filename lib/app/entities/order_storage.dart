import 'package:equatable/equatable.dart';

class OrderStorage extends Equatable {
  final int id;
  final String name;

  const OrderStorage({
    required this.id,
    required this.name,
  });

  @override
  List<Object> get props => [id, name];

  static OrderStorage fromJson(dynamic json) {
    return OrderStorage(
      id: json['id'],
      name: json['name']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name
    };
  }

  @override
  String toString() => 'OrderStorage { id: $id }';
}
