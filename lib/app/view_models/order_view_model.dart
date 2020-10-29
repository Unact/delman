import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/utils/geo_loc.dart';
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
  List<OrderLine> orderLines = [];
  String _message;
  Function _confirmationCallback;
  OrderState _state = OrderState.Initial;
  double _total;
  bool _cardPayment = false;

  OrderViewModel({
    @required BuildContext context,
    @required this.order
  }) : super(context: context) {
    orderLines = appState.orderLines
      .where((e) => e.orderId == order.id)
      .map((e) {
        return OrderLine(
          id: e.id,
          orderId: e.orderId,
          name: e.name,
          amount: e.amount,
          price: e.price,
          factAmount: e.amount
        );
      }).toList();
    _total = _orderLinesTotal;
  }

  OrderState get state => _state;
  String get message => _message;
  Function get confirmationCallback => _confirmationCallback;
  bool get cardPayment => _cardPayment;
  double get total => payment?.summ ?? _total;
  bool get totalEditable => !order.isFinished && payment == null;
  Payment get payment => appState.payments.firstWhere(
    (e) => e.deliveryPointOrderId == order.deliveryPointOrderId,
    orElse: () => null
  );
  List<OrderLine> get sortedOrderLines => orderLines..sort((a, b) => a.name.compareTo(b.name));

  double get _orderLinesTotal {
    return orderLines.fold(0, (prev, el) => prev + (el.factAmount ?? 0) * el.price);
  }

  Future<void> callPhone() async {
    String url = 'tel://${order.phone.replaceAll(RegExp(r'\s|\(|\)|\-'), '')}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _setMessage(Strings.genericErrorMsg);
      _setState(OrderState.Failure);
    }
  }

  void updateOrderLineAmount(OrderLine orderLine, String amount) {
    _updateOrderLineAmount(orderLine, int.tryParse(amount));
    _setState(OrderState.OrderLineChanged);
  }

  void _updateOrderLineAmount(OrderLine orderLine, int amount) {
    OrderLine updatedOrderLine = OrderLine(
      id: orderLine.id,
      orderId: orderLine.orderId,
      name: orderLine.name,
      amount: orderLine.amount,
      price: orderLine.price,
      factAmount: amount
    );

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

    _message = payment == null ? 'Заказ не оплачен!' : 'Вы действительно хотите завершить заказ?';
    _confirmationCallback = confirmOrder;
    _setState(OrderState.NeedUserConfirmation);
  }

  Future<void> confirmOrder(bool confirmed) async {
    if (!confirmed) return;

    _setState(OrderState.InProgress);

    try {
      Location location = await GeoLoc.getCurrentLocation();

      order = await appState.confirmOrder(order, orderLines, location);
      _setMessage('Заказ завершен');
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
      Location location = await GeoLoc.getCurrentLocation();

      order = await appState.cancelOrder(order, location);
      _setMessage('Заказ отменен');
      _setState(OrderState.Canceled);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(OrderState.Failure);
    }
  }

  void _setState(OrderState state) {
    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
