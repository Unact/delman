part of 'delivery_point_order_page.dart';

class DeliveryPointOrderViewModel extends PageViewModel<DeliveryPointOrderState> {
  DeliveryPointOrder deliveryPointOrder;
  late DeliveryPoint deliveryPoint;
  late Order order;
  late List<OrderInfo> orderInfoList = [];
  late List<OrderLine> orderLines = [];
  bool _cardPayment = false;

  DeliveryPointOrderViewModel(BuildContext context, { required this.deliveryPointOrder}) :
    super(context, DeliveryPointOrderInitial()) {
      deliveryPoint = appViewModel.deliveryPoints.firstWhere((e) => e.id == deliveryPointOrder.deliveryPointId);
      order = appViewModel.orders.firstWhere((e) => e.id == deliveryPointOrder.orderId);
      orderInfoList = appViewModel.orderInfoList.where((e) => e.orderId == order.id).toList();
      orderLines = appViewModel.orderLines
        .where((e) => e.orderId == order.id)
        .map((e) => e.factAmount != null ? e : e.copyWith(factAmount: Optional.fromNullable(e.amount)))
        .toList();
    }

  bool get cardPayment => _cardPayment;
  double get total => payment?.summ ?? _orderLinesTotal;
  bool get withCourier => order.storageId == appViewModel.user.storageId;
  bool get isInProgress => !deliveryPointOrder.isFinished && deliveryPoint.inProgress;
  bool get totalEditable => deliveryPointOrder.isFinished &&
    payment == null &&
    !deliveryPointOrder.isPickup &&
    total != 0;
  bool get orderLinesEditable => isInProgress && !deliveryPointOrder.isPickup;
  Payment? get payment => appViewModel.payments
    .firstWhereOrNull((e) => e.deliveryPointOrderId == deliveryPointOrder.id);
  String get orderStatus {
    if (deliveryPointOrder.isCanceled)
      return 'Отменен';

    if (deliveryPointOrder.isPickup)
      return deliveryPointOrder.isFinished ? 'Забран' : 'Ожидает забора';

    return deliveryPointOrder.isFinished ? 'Доставлен' : 'Ожидает доставки';
  }
  bool get hasElevator => deliveryPointOrder.isPickup ? order.hasSenderElevator : order.hasBuyerElevator;
  int? get floor => deliveryPointOrder.isPickup ? order.senderFloor : order.buyerFloor;
  String? get flat => deliveryPointOrder.isPickup ? order.senderFlat : order.buyerFlat;
  String? get personName => deliveryPointOrder.isPickup ? order.senderName : order.buyerName;
  String? get phone => deliveryPointOrder.isPickup ? order.senderPhone : order.buyerPhone;
  DateTime? get dateTimeFrom => deliveryPointOrder.isPickup ? order.pickupDateTimeFrom : order.deliveryDateTimeFrom;
  DateTime? get dateTimeTo => deliveryPointOrder.isPickup ? order.pickupDateTimeTo : order.deliveryDateTimeTo;
  List<OrderInfo> get sortedOrderInfoList => orderInfoList..sort((a, b) => b.ts.compareTo(a.ts));
  List<OrderLine> get sortedOrderLines => orderLines..sort((a, b) => a.name.compareTo(b.name));

  double get _orderLinesTotal {
    return orderLines.fold(0, (prev, el) => prev + (el.factAmount ?? 0) * el.price);
  }

  Future<void> callPhone() async {
    await Misc.callPhone(deliveryPointOrder.isPickup ? order.senderPhone : order.buyerPhone, onFailure: () {
      emit(DeliveryPointOrderFailure(Strings.genericErrorMsg));
    });
  }

  void updateOrderLineAmount(OrderLine orderLine, String amount) {
    int? intAmount = int.tryParse(amount);
    _updateOrderLineAmount(orderLine, intAmount);
    emit(DeliveryPointOrderLineChanged());
    String text = '$intAmount';

    FLog.debug(text: text);
  }

  void _updateOrderLineAmount(OrderLine orderLine, int? amount) {
    OrderLine updatedOrderLine = orderLine.copyWith(factAmount: Optional.fromNullable(amount));

    orderLines.removeWhere((e) => e.id == orderLine.id);
    orderLines.add(updatedOrderLine);
  }

  void tryStartPayment(bool cardPayment) {
    if (total == 0 || total < 0) {
      emit(DeliveryPointOrderFailure('Указана некорректная сумма'));

      return;
    }

    _cardPayment = cardPayment;
    emit(DeliveryPointOrderNeedUserConfirmation(
      'Вы действительно хотите оплатить заказ ${cardPayment ? 'картой' : 'наличными'}?',
      startPayment
    ));
  }

  Future<void> startPayment(bool confirmed) async {
    if (!confirmed) return;

    emit(DeliveryPointOrderPaymentStarted());
  }

  void finishPayment(String result) {
    emit(DeliveryPointOrderPaymentFinished(result));
  }

  void tryConfirmOrder() {
    List<String> messages = [];
    String typeMsgPart = deliveryPointOrder.isPickup ? 'забор' : 'доставку';

    if (orderLines.any((e) => e.factAmount == null || e.factAmount! < 0)) {
      emit(DeliveryPointOrderFailure('Не для всех позиций указан факт'));

      return;
    }

    if (order.needDocumentsReturn) messages.add('Вы забрали документы?');
    if (messages.isEmpty) messages.add('Вы действительно хотите завершить $typeMsgPart заказа?');

    emit(DeliveryPointOrderNeedUserConfirmation(messages.join('\n'), confirmOrder));
  }

  Future<void> confirmOrder(bool confirmed) async {
    if (!confirmed) {
      if (order.needDocumentsReturn) {
        emit(DeliveryPointOrderFailure('Нельзя завершить заказ без возврата документов'));
        return;
      }

      emit(DeliveryPointOrderFailure(''));
      return;
    }

    emit(DeliveryPointOrderInProgress());

    try {
      deliveryPointOrder = await appViewModel.confirmOrder(deliveryPointOrder, orderLines);

      String message = deliveryPointOrder.isPickup ? 'Забор заказа завершен' : 'Доставка заказа завершена';
      emit(DeliveryPointOrderConfirmed(message));
    } on AppError catch(e) {
      emit(DeliveryPointOrderFailure(e.message));
    }
  }

  void tryCancelOrder() {
    emit(DeliveryPointOrderNeedUserConfirmation('Вы действительно хотите отменить заказ?', cancelOrder));
  }

  Future<void> cancelOrder(bool confirmed) async {
    if (!confirmed) return;

    emit(DeliveryPointOrderInProgress());

    try {
      deliveryPointOrder = await appViewModel.cancelOrder(deliveryPointOrder);
      emit(DeliveryPointOrderCanceled('Заказ отменен'));
    } on AppError catch(e) {
      emit(DeliveryPointOrderFailure(e.message));
    }
  }

  Future<void> addComment(String newOrderInfoComment) async {
    emit(DeliveryPointOrderInProgress());

    try {
      orderInfoList.add(await appViewModel.addOrderInfo(order, newOrderInfoComment));
      emit(DeliveryPointOrderCommentAdded('Комментарий добавлен'));
    } on AppError catch(e) {
      emit(DeliveryPointOrderFailure(e.message));
    }
  }
}
