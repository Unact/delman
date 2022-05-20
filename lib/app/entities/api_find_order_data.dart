part of 'entities.dart';

class ApiFindOrderData {
  List<ApiOrderInfoLine> orderInfoList;
  List<ApiOrderLine> orderLines;
  ApiOrder order;

  ApiFindOrderData({
    required this.orderInfoList,
    required this.orderLines,
    required this.order,
  });

  factory ApiFindOrderData.fromJson(Map<String, dynamic> json) {
    return ApiFindOrderData(
      orderInfoList: json['orderInfoList'].map<ApiOrderInfoLine>((e) => ApiOrderInfoLine.fromJson(e)).toList(),
      orderLines: json['orderLines'].map<ApiOrderLine>((e) => ApiOrderLine.fromJson(e)).toList(),
      order: ApiOrder.fromJson(json['order'])
    );
  }
}
