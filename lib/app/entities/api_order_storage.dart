part of 'entities.dart';

class ApiOrderStorage extends Equatable {
  final int id;
  final String name;

  const ApiOrderStorage({
    required this.id,
    required this.name,
  });

  factory ApiOrderStorage.fromJson(dynamic json) {
    return ApiOrderStorage(
      id: json['id'],
      name: json['name']
    );
  }

  OrderStorage toDatabaseEnt() {
    return OrderStorage(
      id: id,
      name: name
    );
  }

  @override
  List<Object> get props => [
    id,
    name
  ];
}
