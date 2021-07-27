import 'package:collection/collection.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum OrderState {
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

class OrderViewModel extends BaseViewModel {
  Order order;
  DeliveryPoint deliveryPoint;
  late List<OrderInfo> orderInfoList = [];
  late List<OrderLine> orderLines = [];
  String? _message;
  Function? _confirmationCallback;
  OrderState _state = OrderState.Initial;
  late double _total;
  bool _cardPayment = false;

  OrderViewModel({
    required BuildContext context,
    required this.order,
    required this.deliveryPoint
  }) : super(context: context) {
    orderInfoList = appState.orderInfoList.where((e) => e.orderId == order.orderId).toList();
    orderLines = appState.orderLines
      .where((e) => e.orderId == order.orderId)
      .map((e) => e.copyWith(factAmount: e.amount))
      .toList();
    _total = _orderLinesTotal;
  }

  OrderState get state => _state;
  String? get message => _message;
  Function? get confirmationCallback => _confirmationCallback;
  bool get cardPayment => _cardPayment;
  double get total => payment?.summ ?? _total;
  bool get withCourier => appState.userStorageOrders.any((e) => e.orderId == order.orderId);
  bool get isInProgress => !order.isFinished && deliveryPoint.inProgress;
  bool get totalEditable => isInProgress && payment == null && !order.isPickup;
  bool get needPayment => totalEditable && orderLines.any((el) => el.price != 0);
  bool get needDocumentsReturn => order.needDocumentsReturn && !order.isPickup;
  Payment? get payment => appState.payments.firstWhereOrNull((e) => e.deliveryPointOrderId == order.id);
  String get orderStatus {
    if (order.isCanceled)
      return 'Отменен';

    if (order.isPickup)
      return order.isFinished ? 'Забран' : 'Ожидает забора';

    return order.isFinished ? 'Доставлен' : 'Ожидает доставки';
  }
  List<OrderInfo> get sortedOrderInfoList => orderInfoList..sort((a, b) => b.ts.compareTo(a.ts));
  List<OrderLine> get sortedOrderLines => orderLines..sort((a, b) => a.name.compareTo(b.name));

  double get _orderLinesTotal {
    return orderLines.fold(0, (prev, el) => prev + (el.factAmount ?? 0) * el.price);
  }

  Future<void> callPhone() async {
    await Misc.callPhone(order.phone, onFailure: () {
      _setMessage(Strings.genericErrorMsg);
      _setState(OrderState.Failure);
    });
  }

  void updateOrderLineAmount(OrderLine orderLine, String amount) {
    int? intAmount = int.tryParse(amount);
    _updateOrderLineAmount(orderLine, intAmount);
    _setState(OrderState.OrderLineChanged);
    String text = '$intAmount';

    FLog.debug(text: text);
  }

  void _updateOrderLineAmount(OrderLine orderLine, int? amount) {
    OrderLine updatedOrderLine = orderLine.copyWith(factAmount: amount);

    orderLines.removeWhere((e) => e.id == orderLine.id);
    orderLines.add(updatedOrderLine);

    _total = _orderLinesTotal;
  }

  void tryStartPayment(bool cardPayment) {
    if (_total == 0 || _total < 0) {
      _setMessage('Указана некорректная сумма');
      _setState(OrderState.Failure);

      return;
    }

    _cardPayment = cardPayment;
    _confirmationCallback = startPayment;
    _setMessage('Вы действительно хотите оплатить заказ ${cardPayment ? 'картой' : 'наличными'}?');
    _setState(OrderState.NeedUserConfirmation);
  }

  Future<void> startPayment(bool confirmed) async {
    if (!confirmed) return;

    _setState(OrderState.PaymentStarted);
  }

  void finishPayment(String result) {
    _setMessage(result);
    _setState(OrderState.PaymentFinished);
  }

  void tryConfirmOrder() {
    List<String> messages = [];
    String typeMsgPart = order.isPickup ? 'забор' : 'доставку';

    if (orderLines.any((e) => e.factAmount == null || e.factAmount! < 0)) {
      _setMessage('Не для всех позиций указан факт');
      _setState(OrderState.Failure);

      return;
    }

    if (needPayment) messages.add('Заказ не оплачен!');
    if (needDocumentsReturn) messages.add('Вы забрали документы?');
    if (messages.isEmpty) messages.add('Вы действительно хотите завершить $typeMsgPart заказа?');

    _confirmationCallback = confirmOrder;
    _setMessage(messages.join('\n'));
    _setState(OrderState.NeedUserConfirmation);
  }

  Future<void> confirmOrder(bool confirmed) async {
    if (!confirmed) {
      _setMessage('');

      if (needDocumentsReturn) {
        _setMessage('Нельзя завершить заказ, без возврата документов');
      }

      _setState(OrderState.Failure);

      return;
    }

    _setState(OrderState.InProgress);

    try {
      order = await appState.confirmOrder(order, orderLines);
      _setMessage(order.isPickup ? 'Забор заказа завершен' : 'Доставка заказа завершена');
      _setState(OrderState.Confirmed);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(OrderState.Failure);
    }
  }

  void tryCancelOrder() {
    _confirmationCallback = cancelOrder;
    _setMessage('Вы действительно хотите отменить заказ?');
    _setState(OrderState.NeedUserConfirmation);
  }

  Future<void> cancelOrder(bool confirmed) async {
    if (!confirmed) return;

    _setState(OrderState.InProgress);

    try {
      order = await appState.cancelOrder(order);
      _setMessage('Заказ отменен');
      _setState(OrderState.Canceled);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(OrderState.Failure);
    }
  }

  Future<void> addComment(String newOrderInfoComment) async {
    _setState(OrderState.InProgress);

    try {
      orderInfoList.add(await appState.addOrderInfo(order, newOrderInfoComment));
      _setMessage('Комментарий добавлен');
      _setState(OrderState.OrderInfoCommentAdded);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(OrderState.Failure);
    }
  }

  void _setState(OrderState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
