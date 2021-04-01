import 'dart:async';
import 'dart:typed_data';

import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';

import 'package:delman/app/app_state.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/iboxpro.dart';
import 'package:delman/app/utils/misc.dart';
import 'package:delman/app/view_models/base_view_model.dart';

enum AcceptPaymentState {
  Initial,
  SearchingForDevice,
  GettingCredentials,
  PaymentAuthorization,
  WaitingForPayment,
  PaymentStarted,
  PaymentFinished,
  RequiredSignature,
  SavingSignature,
  SavingPayment,
  Finished,
  Failure
}

class AcceptPaymentViewModel extends BaseViewModel {
  Order order;
  String _message = 'Инициализация платежа';
  AcceptPaymentState _state = AcceptPaymentState.Initial;
  bool _canceled = false;
  bool _isCancelable = false;
  double total;
  bool cardPayment;
  bool _requiredSignature = false;
  Iboxpro iboxpro = Iboxpro();

  AcceptPaymentViewModel({
    @required BuildContext context,
    @required this.total,
    @required this.cardPayment,
    @required this.order
  }) : super(context: context) {
    if (!cardPayment) {
      _savePayment();
    } else {
      _connectToDevice();
    }
  }

  AcceptPaymentState get state => _state;
  String get message => _message;

  bool get requiredSignature => _requiredSignature;
  bool get isCancelable => _isCancelable;

  Future<void> cancelPayment() async {
    _canceled = true;
    await iboxpro.cancelPayment();

    _setMessage('Платеж отменен');
    _setState(AcceptPaymentState.Failure);
  }

  Future<void> _connectToDevice() async {
    _isCancelable = true;
    _setMessage('Установление связи с терминалом');
    _setState(AcceptPaymentState.SearchingForDevice);

    iboxpro.connectToDevice(
      onError: (String error) {
        _setMessage(error);
        _setState(AcceptPaymentState.Failure);
      },
      onConnected: _getPaymentCredentials
    );
  }

  Future<void> _getPaymentCredentials() async {
    if (_canceled) return;

    _setMessage('Установление связи с сервером');
    _setState(AcceptPaymentState.GettingCredentials);

    try {
      Map<String, dynamic> credentials = await appState.getPaymentCredentials();

      await _apiLogin(credentials['login'], credentials['password']);
    } on AppError catch(e) {
      _setMessage(e.message);
      _setState(AcceptPaymentState.Failure);
    }
  }

  Future<void> _apiLogin(String login, String password) async {
    if (_canceled) return;

    _setMessage('Авторизация оплаты');
    _setState(AcceptPaymentState.PaymentAuthorization);

    await iboxpro.apiLogin(
      login: login,
      password: password,
      onError: (String error) {
        _setMessage(error);
        _setState(AcceptPaymentState.Failure);
      },
      onLogin: _startPayment
    );
  }

  Future<void> _startPayment() async {
    if (_canceled) return;

    _setMessage('Ожидание ответа от терминала');
    _setState(AcceptPaymentState.WaitingForPayment);

    await iboxpro.startPayment(
      amount: total,
      description: 'Оплата за заказ ${order.trackingNumber}',
      onError: (String error) {
        _setMessage(error);
        _setState(AcceptPaymentState.Failure);
      },
      onPaymentStart: (_) {
        _isCancelable = false;
        _setMessage('Обработка оплаты');
        _setState(AcceptPaymentState.PaymentStarted);
      },
      onPaymentComplete: (Map<dynamic, dynamic> transaction, bool requiredSignature) {
        _requiredSignature = requiredSignature;
        _setMessage('Подтверждение оплаты');
        _setState(AcceptPaymentState.PaymentFinished);

        if (!_requiredSignature) {
          _savePayment(transaction);
        } else {
          _setMessage('Для завершения оплаты\nнеобходимо указать подпись');
          _setState(AcceptPaymentState.RequiredSignature);
        }
      }
    );
  }

  Future<void> adjustPayment(Uint8List signature) async {
    _requiredSignature = false;
    _setMessage('Сохранение подписи клиента');
    _setState(AcceptPaymentState.SavingSignature);

    await iboxpro.adjustPayment(
      signature: signature,
      onError: (String error) {
        _setMessage(error);
        _setState(AcceptPaymentState.Failure);
      },
      onPaymentAdjust: _savePayment
    );
  }

  Future<void> _savePayment([Map<dynamic, dynamic> transaction]) async {
    _setMessage('Сохранение информации об оплате');
    _setState(AcceptPaymentState.SavingPayment);

    Payment payment = Payment(
      deliveryPointOrderId: order.id,
      summ: total,
      transactionId: transaction != null ? transaction['id'] : null
    );
    try {
      await appState.acceptPayment(payment, transaction);

      _setMessage('Оплата успешно сохранена');
      _setState(AcceptPaymentState.Finished);
    } on AppError catch(e) {
      _setMessage('Ошибка при сохранении оплаты ${e.message}');
      _setState(AcceptPaymentState.Failure);
    }
  }

  void _setState(AcceptPaymentState state) {
    FLog.info(methodName: Misc.stackFrame(1)['methodName'], text: state.toString());

    _state = state;
    if (!disposed) notifyListeners();
  }

  void _setMessage(String message) {
    _message = message;
  }
}
