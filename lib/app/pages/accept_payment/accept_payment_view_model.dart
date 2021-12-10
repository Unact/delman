part of 'accept_payment_page.dart';

class AcceptPaymentViewModel extends PageViewModel<AcceptPaymentState> {
  late Order order;
  DeliveryPointOrder deliveryPointOrder;
  bool _canceled = false;
  bool _isCancelable = false;
  double total;
  bool cardPayment;
  bool _requiredSignature = false;
  Iboxpro iboxpro = Iboxpro();

  AcceptPaymentViewModel(BuildContext context, {
    required this.total,
    required this.cardPayment,
    required this.deliveryPointOrder
  }) : super(context, AcceptPaymentInitial('Инициализация платежа')) {
    order = appViewModel.orders.firstWhere((e) => e.id == deliveryPointOrder.orderId);

    if (!cardPayment) {
      _savePayment();
    } else {
      _connectToDevice();
    }
  }

  bool get requiredSignature => _requiredSignature;
  bool get isCancelable => _isCancelable;

  Future<void> cancelPayment() async {
    _canceled = true;
    await iboxpro.cancelPayment();

    emit(AcceptPaymentFailure('Платеж отменен'));
  }

  Future<void> _connectToDevice() async {
    _isCancelable = true;

    emit(AcceptPaymentSearchingForDevice('Установление связи с терминалом'));

    iboxpro.connectToDevice(
      onError: (String error) => emit(AcceptPaymentFailure(error)),
      onConnected: _getPaymentCredentials
    );
  }

  Future<void> _getPaymentCredentials() async {
    if (_canceled) return;

    emit(AcceptPaymentGettingCredentials('Установление связи с сервером'));

    try {
      PaymentCredentials credentials = await appViewModel.getPaymentCredentials();

      await _apiLogin(credentials.login, credentials.password);
    } on AppError catch(e) {
      emit(AcceptPaymentFailure(e.message));
    }
  }

  Future<void> _apiLogin(String login, String password) async {
    if (_canceled) return;

    emit(AcceptPaymentPaymentAuthorization('Авторизация оплаты'));

    await iboxpro.apiLogin(
      login: login,
      password: password,
      onError: (String error) => emit(AcceptPaymentFailure(error)),
      onLogin: _startPayment
    );
  }

  Future<void> _startPayment() async {
    if (_canceled) return;

    emit(AcceptPaymentWaitingForPayment('Ожидание ответа от терминала'));

    await iboxpro.startPayment(
      amount: total,
      description: 'Оплата за заказ ${order.trackingNumber}',
      onError: (String error) => emit(AcceptPaymentFailure(error)),
      onPaymentStart: (_) {
        _isCancelable = false;
        emit(AcceptPaymentPaymentStarted('Обработка оплаты'));
      },
      onPaymentComplete: (Map<dynamic, dynamic> transaction, bool requiredSignature) {
        _requiredSignature = requiredSignature;
        emit(AcceptPaymentPaymentFinished('Подтверждение оплаты'));

        if (!_requiredSignature) {
          _savePayment(transaction);
        } else {
          emit(AcceptPaymentRequiredSignature('Для завершения оплаты\nнеобходимо указать подпись'));
        }
      }
    );
  }

  Future<void> adjustPayment(Uint8List signature) async {
    _requiredSignature = false;
    emit(AcceptPaymentSavingSignature('Сохранение подписи клиента'));

    await iboxpro.adjustPayment(
      signature: signature,
      onError: (String error) => emit(AcceptPaymentFailure(error)),
      onPaymentAdjust: _savePayment
    );
  }

  Future<void> _savePayment([Map<dynamic, dynamic>? transaction]) async {
    emit(AcceptPaymentSavingPayment('Сохранение информации об оплате'));

    Payment payment = Payment(
      deliveryPointOrderId: deliveryPointOrder.id,
      summ: total,
      transactionId: transaction != null ? transaction['id'] : null
    );
    try {
      await appViewModel.acceptPayment(payment, transaction);
      emit(AcceptPaymentFinished('Оплата успешно сохранена'));
    } on AppError catch(e) {
      emit(AcceptPaymentFailure('Ошибка при сохранении оплаты ${e.message}'));
    }
  }
}
