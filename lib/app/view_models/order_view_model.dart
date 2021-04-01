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
  Failure
}

class OrderViewModel extends BaseViewModel {
  Order order;
  DeliveryPoint deliveryPoint;
  List<OrderLine> orderLines = [];
  String _message;
  Function _confirmationCallback;
  OrderState _state = OrderState.Initial;
  double _total;
  bool _cardPayment = false;

  OrderViewModel({
    @required BuildContext context,
    @required this.order,
    @required this.deliveryPoint
  }) : super(context: context) {
    orderLines = appState.orderLines
      .where((e) => e.orderId == order.orderId)
      .map((e) => e.copyWith(factAmount: e.amount))
      .toList();
    _total = _orderLinesTotal;
  }

  OrderState get state => _state;
  String get message => _message;
  Function get confirmationCallback => _confirmationCallback;
  bool get cardPayment => _cardPayment;
  double get total => payment?.summ ?? _total;
  bool get isInProgress => !order.isFinished && deliveryPoint.inProgress;
  bool get totalEditable => isInProgress && payment == null && !order.isPickup;
  bool get needPayment => totalEditable && orderLines.any((el) => el.price != 0);
  Payment get payment => appState.payments.firstWhere(
    (e) => e.deliveryPointOrderId == order.id,
    orElse: () => null
  );
  String get orderStatus {
    if (order.isCanceled)
      return 'Отменен';

    if (order.isPickup)
      return order.isFinished ? 'Забран' : 'Ожидает забора';

    return order.isFinished ? 'Доставлен' : 'Ожидает доставки';
  }
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
    int intAmount = int.tryParse(amount);
    _updateOrderLineAmount(orderLine, intAmount);
    _setState(OrderState.OrderLineChanged);
    String text = '$intAmount';

    FLog.debug(text: text);
  }

  void _updateOrderLineAmount(OrderLine orderLine, int amount) {
    OrderLine updatedOrderLine = orderLine.copyWith(factAmount: amount);

    orderLines.removeWhere((e) => e.id == orderLine.id);
    orderLines.add(updatedOrderLine);

    _total = _orderLinesTotal;
  }

  void tryStartPayment(bool cardPayment) {
    if (_total == null || _total == 0 || _total < 0) {
      _setMessage('Указана некорректная сумма');
      _setState(OrderState.Failure);

      return;
    }

    _cardPayment = cardPayment;
    _message = 'Вы действительно хотите оплатить заказ ${cardPayment ? 'картой' : 'наличными'}?';
    _confirmationCallback = startPayment;
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
    if (orderLines.any((e) => e.factAmount == null || e.factAmount < 0)) {
      _setMessage('Не для всех позиций указан факт');
      _setState(OrderState.Failure);

      return;
    }

    _message = needPayment ?
      'Заказ не оплачен!' :
      'Вы действительно хотите завершить ${order.isPickup ? 'забор' : 'доставку' } заказа?';
    _confirmationCallback = confirmOrder;
    _setState(OrderState.NeedUserConfirmation);
  }

  Future<void> confirmOrder(bool confirmed) async {
    if (!confirmed) return;

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
    _message = 'Вы действительно хотите отменить заказ?';
    _confirmationCallback = cancelOrder;
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

  void _setState(OrderState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
