part of 'delivery_point_page.dart';

class DeliveryPointViewModel extends PageViewModel<DeliveryPointState> {
  DeliveryPoint deliveryPoint;

  DeliveryPointViewModel(BuildContext context, {required this.deliveryPoint}) : super(context, DeliveryPointInitial());

  List<DeliveryPointOrder> get deliveryPointOrders => appViewModel.deliveryPointOrders
    .where((e) => e.deliveryPointId == deliveryPoint.id && !e.isPickup)
    .toList()
    ..sort((a, b) => getOrder(a).trackingNumber.compareTo(getOrder(b).trackingNumber));

  List<DeliveryPointOrder> get pickupPointOrders => appViewModel.deliveryPointOrders
    .where((e) => e.deliveryPointId == deliveryPoint.id && e.isPickup)
    .toList()
    ..sort((a, b) => getOrder(a).trackingNumber.compareTo(getOrder(b).trackingNumber));

  Order getOrder(DeliveryPointOrder deliveryPointOrder) {
    return appViewModel.orders.firstWhere((e) => e.id == deliveryPointOrder.orderId);
  }

  Future<void> callPhone() async {
    await Misc.callPhone(deliveryPoint.phone, onFailure: () {
      emit(DeliveryPointFailure(Strings.genericErrorMsg));
    });
  }

  Future<void> copyOrderInfo(Order order) async {
    String text = 'ИМ: ${order.sellerName}\n' +
      'Номер в ИМ: ${order.number}\n' +
      'Трекинг: ${order.trackingNumber}\n' +
      'Адрес: ${deliveryPoint.addressName}';
    await Clipboard.setData(ClipboardData(text: text));

    emit(DeliveryPointOrderDataCopied('Данные о заказе скопированы'));
  }

  Future<void> arrive() async {
    emit(DeliveryPointInProgress());

    try {
      deliveryPoint = await appViewModel.arriveAtDeliveryPoint(deliveryPoint);

      emit(DeliveryPointArrivalSaved('Прибытие успешно отмечено'));
    } on AppError catch(e) {
      emit(DeliveryPointFailure(e.message));
    }
  }
}
