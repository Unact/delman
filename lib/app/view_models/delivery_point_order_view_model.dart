import 'package:collection/collection.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:quiver/core.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum DeliveryPointOrderState {
  Initial,
  InProgress,
  NeedUserConfirmation,
  OrderLineChanged,
  PaymentStarted,
  PaymentFinished,
  Confirmed,
  Canceled,
  OrderInfoCommentAdded,
  Failure
}

class DeliveryPointOrderViewModel extends BaseViewModel {
  DeliveryPointOrder deliveryPointOrder;
  late DeliveryPoint deliveryPoint;
  late Order order;
  late List<OrderInfo> orderInfoList = [];
  late List<OrderLine> orderLines = [];
  String? _message;
  Function? _confirmationCallback;
  DeliveryPointOrderState _state = DeliveryPointOrderState.Initial;
  bool _cardPayment = false;

  DeliveryPointOrderViewModel({
    required BuildContext context,
    required this.deliveryPointOrder
  }) : super(context: context) {
    deliveryPoint = appState.deliveryPoints.firstWhere((e) => e.id == deliveryPointOrder.deliveryPointId);
    order = appState.orders.firstWhere((e) => e.id == deliveryPointOrder.orderId);
    orderInfoList = appState.orderInfoList.where((e) => e.orderId == order.id).toList();
    orderLines = appState.orderLines
      .where((e) => e.orderId == order.id)
      .map((e) => e.factAmount != null ? e : e.copyWith(factAmount: Optional.fromNullable(e.amount)))
      .toList();
  }

  DeliveryPointOrderState get state => _state;
  String? get message => _message;
  Function? get confirmationCallback => _confirmationCallback;
  bool get cardPayment => _cardPayment;
  double get total => payment?.summ ?? _orderLinesTotal;
  bool get withCourier => order.storageId == appState.user.storageId;
  bool get isInProgress => !deliveryPointOrder.isFinished && deliveryPoint.inProgress;
  bool get totalEditable => deliveryPointOrder.isFinished &&
    payment == null &&
    !deliveryPointOrder.isPickup &&
    total != 0;
  bool get orderLinesEditable => isInProgress && !deliveryPointOrder.isPickup;
  Payment? get payment => appState.payments.firstWhereOrNull((e) => e.deliveryPointOrderId == deliveryPointOrder.id);
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
      _setMessage(Strings.genericErrorMsg);
      _setState(DeliveryPointOrderState.Failure);
    });
  }

  void updateOrderLineAmount(OrderLine orderLine, String amount) {
    int? intAmount = int.tryParse(amount);
    _updateOrderLineAmount(orderLine, intAmount);
    _setState(DeliveryPointOrderState.OrderLineChanged);
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
      _setMessage('Указана некорректная сумма');
      _setState(DeliveryPointOrderState.Failure);

      return;
    }

    _cardPayment = cardPayment;
    _confirmationCallback = startPayment;
    _setMessage('Вы действительно хотите оплатить заказ ${cardPayment ? 'картой' : 'наличными'}?');
    _setState(DeliveryPointOrderState.NeedUserConfirmation);
  }

  Future<void> startPayment(bool confirmed) async {
    if (!confirmed) return;

    _setState(DeliveryPointOrderState.PaymentStarted);
  }

  void finishPayment(String result) {
    _setMessage(result);
    _setState(DeliveryPointOrderState.PaymentFinished);
  }

  void tryConfirmOrder() {
    List<String> messages = [];
    String typeMsgPart = deliveryPointOrder.isPickup ? 'забор' : 'доставку';

    if (orderLines.any((e) => e.factAmount == null || e.factAmount! < 0)) {
      _setMessage('Не для всех позиций указан факт');
      _setState(DeliveryPointOrderState.Failure);

      return;
    }

    if (order.needDocumentsReturn) messages.add('Вы забрали документы?');
    if (messages.isEmpty) messages.add('Вы действительно хотите завершить $typeMsgPart заказа?');

    _confirmationCallback = confirmOrder;
    _setMessage(messages.join('\n'));
    _setState(DeliveryPointOrderState.NeedUserConfirmation);
  }

  Future<void> confirmOrder(bool confirmed) async {
    if (!confirmed) {
      _setMessage('');

      if (order.needDocumentsReturn) {
        _setMessage('Нельзя завершить заказ без возврата документов');
      }

      _setState(DeliveryPointOrderState.Failure);

      return;
    }

    _setState(DeliveryPointOrderState.InProgress);

    try {
      deliveryPointOrder = await appState.confirmOrder(deliveryPointOrder, orderLines);
      _setMessage(deliveryPointOrder.isPickup ? 'Забор заказа завершен' : 'Доставка заказа завершена');
      _setState(DeliveryPointOrderState.Confirmed);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(DeliveryPointOrderState.Failure);
    }
  }

  void tryCancelOrder() {
    _confirmationCallback = cancelOrder;
    _setMessage('Вы действительно хотите отменить заказ?');
    _setState(DeliveryPointOrderState.NeedUserConfirmation);
  }

  Future<void> cancelOrder(bool confirmed) async {
    if (!confirmed) return;

    _setState(DeliveryPointOrderState.InProgress);

    try {
      deliveryPointOrder = await appState.cancelOrder(deliveryPointOrder);
      _setMessage('Заказ отменен');
      _setState(DeliveryPointOrderState.Canceled);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(DeliveryPointOrderState.Failure);
    }
  }

  Future<void> addComment(String newOrderInfoComment) async {
    _setState(DeliveryPointOrderState.InProgress);

    try {
      orderInfoList.add(await appState.addOrderInfo(order, newOrderInfoComment));
      _setMessage('Комментарий добавлен');
      _setState(DeliveryPointOrderState.OrderInfoCommentAdded);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(DeliveryPointOrderState.Failure);
    }
  }

  void _setState(DeliveryPointOrderState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
