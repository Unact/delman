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
  bool get cardPayment => _cardPayment;
  double get total => payment?.summ ?? _total;
  bool get totalEditable => !order.isFinished && payment == null;
  Payment get payment => appState.payments.firstWhere(
    (e) => e.deliveryPointOrderId == order.deliveryPointOrderId,
    orElse: () => null
  );
  List<OrderLine> get sortedOrderLines => orderLines..sort((a, b) => a.name.compareTo(b.name));

  double get _orderLinesTotal => orderLines.fold(0, (prev, element) => prev + element.currentAmount * element.price);

  Future<void> callPhone() async {
    String url = 'tel://${order.phone}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _setMessage(Strings.genericErrorMsg);
      _setState(OrderState.Failure);
    }
  }

  void updateTotal(String totalStr) {
    String formattedValue = totalStr.replaceAll(',', '.').replaceAll(RegExp(r'\s\b|\b\s'), '');

    try {
      _total = double.parse(formattedValue);
    } on FormatException {}
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

  Future<void> startPayment(bool cardPayment) async {
    if (_total != null && _total != 0 && _total > 0) {
      _cardPayment = cardPayment;
      _setState(OrderState.PaymentStarted);

      return;
    }

    _setMessage('Указана некорректная сумма');
    _setState(OrderState.Failure);
  }

  void finishPayment(String result) {
    _setMessage(result);
    _setState(OrderState.PaymentFinished);
  }

  Future<void> tryConfirmOrder() async {
    if (orderLines.any((e) => e.factAmount == null || e.factAmount < 0)) {
      _setMessage('Не для всех позиций указан факт');
      _setState(OrderState.Failure);

      return;
    }

    if (payment == null) {
      _setState(OrderState.NeedUserConfirmation);

      return;
    }

    confirmOrder(true);
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

  Future<void> cancelOrder() async {
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
