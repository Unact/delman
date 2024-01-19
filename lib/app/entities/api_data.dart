part of 'entities.dart';

class ApiData extends Equatable {
  final List<ApiDeliveryPoint> deliveryPoints;
  final List<ApiDelivery> deliveries;
  final List<ApiOrderInfoLine> orderInfoList;
  final List<ApiOrderLine> orderLines;
  final List<ApiOrder> orders;
  final List<ApiDeliveryPointOrder> deliveryPointOrders;
  final List<ApiOrderStorage> orderStorages;
  final List<ApiPayment> payments;

  ApiData({
    required this.deliveryPoints,
    required this.deliveries,
    required this.orderInfoList,
    required this.orderLines,
    required this.orders,
    required this.deliveryPointOrders,
    required this.orderStorages,
    required this.payments,
  });

  factory ApiData.fromJson(Map<String, dynamic> json) {
    return ApiData(
      deliveryPoints: json['deliveryPoints']
        .map<ApiDeliveryPoint>((e) => ApiDeliveryPoint.fromJson(e)).toList(),
      deliveryPointOrders: json['deliveryPointOrders']
        .map<ApiDeliveryPointOrder>((e) => ApiDeliveryPointOrder.fromJson(e)).toList(),
      deliveries: json['deliveries']
        .map<ApiDelivery>((e) => ApiDelivery.fromJson(e)).toList(),
      orderInfoList: json['orderInfoList']
        .map<ApiOrderInfoLine>((e) => ApiOrderInfoLine.fromJson(e)).toList(),
      orderLines: json['orderLines']
        .map<ApiOrderLine>((e) => ApiOrderLine.fromJson(e)).toList(),
      orders: json['orders']
        .map<ApiOrder>((e) => ApiOrder.fromJson(e)).toList(),
      orderStorages: json['orderStorages']
        .map<ApiOrderStorage>((e) => ApiOrderStorage.fromJson(e)).toList(),
      payments: json['payments']
        .map<ApiPayment>((e) => ApiPayment.fromJson(e)).toList(),
    );
  }

  @override
  List<Object> get props => [
    deliveryPoints,
    deliveries,
    orderInfoList,
    orderLines,
    orders,
    deliveryPointOrders,
    orderStorages,
    payments,
  ];
}
