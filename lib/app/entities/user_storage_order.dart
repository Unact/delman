import 'package:equatable/equatable.dart';

class UserStorageOrder extends Equatable {
  final int orderId;
  final String trackingNumber;

  const UserStorageOrder({
    required this.orderId,
    required this.trackingNumber
  });

  @override
  List<Object> get props => [orderId, trackingNumber];

  static UserStorageOrder fromJson(dynamic json) {
    return UserStorageOrder(
      orderId: json['orderId'],
      trackingNumber: json['trackingNumber']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': this.orderId,
      'trackingNumber': this.trackingNumber
    };
  }

  UserStorageOrder copyWith({
    int? orderId,
    String? trackingNumber,
  }) {
    return UserStorageOrder(
      orderId: orderId ?? this.orderId,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  @override
  String toString() => 'UserStorageOrder { orderId: $orderId }';
}
