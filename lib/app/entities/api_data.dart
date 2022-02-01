part of 'entities.dart';

class ApiData {
  List<ApiDeliveryPoint> deliveryPoints;
  List<ApiDelivery> deliveries;
  List<ApiOrderInfoLine> orderInfoList;
  List<ApiOrderLine> orderLines;
  List<ApiOrder> orders;
  List<ApiDeliveryPointOrder> deliveryPointOrders;
  List<ApiOrderStorage> orderStorages;
  List<ApiPayment> payments;

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
}
