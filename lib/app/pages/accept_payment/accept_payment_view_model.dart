part of 'accept_payment_page.dart';

class AcceptPaymentViewModel extends PageViewModel<AcceptPaymentState, AcceptPaymentStateStatus> {
  Iboxpro iboxpro = Iboxpro();

  AcceptPaymentViewModel(BuildContext context, {
    required double total,
    required bool cardPayment,
    required DeliveryPointOrderExResult deliveryPointOrderEx
  }) : super(context, AcceptPaymentState(
    message: 'Инициализация платежа',
    total: total,
    cardPayment: cardPayment,
    deliveryPointOrderEx: deliveryPointOrderEx
  ));

  @override
  AcceptPaymentStateStatus get status => state.status;

  @override
  Future<void> loadData() async {}

  @override
  Future<void> initViewModel() async {
    super.initViewModel();

    if (!state.cardPayment) {
      _savePayment();
    } else {
      _connectToDevice();
    }
  }

  Future<void> cancelPayment() async {
    await iboxpro.cancelPayment();

    emit(state.copyWith(message: 'Платеж отменен', canceled: true));
  }

  Future<void> _connectToDevice() async {
    emit(state.copyWith(
      message: 'Установление связи с терминалом',
      status: AcceptPaymentStateStatus.searchingForDevice
    ));

    iboxpro.connectToDevice(
      onError: (String error) => emit(state.copyWith(message: error, status: AcceptPaymentStateStatus.failure)),
      onConnected: _getPaymentCredentials
    );
  }

  Future<void> _getPaymentCredentials() async {
    if (state.canceled) return;

    emit(state.copyWith(message: 'Установление связи с сервером', status: AcceptPaymentStateStatus.gettingCredentials));

    try {
      ApiPaymentCredentials credentials = await _getApiPaymentCredentials();

      await _apiLogin(credentials.login, credentials.password);
    } on AppError catch(e) {
      emit(state.copyWith(message: e.message, status: AcceptPaymentStateStatus.failure));
    }
  }

  Future<void> _apiLogin(String login, String password) async {
    if (state.canceled) return;

    emit(state.copyWith(message: 'Авторизация оплаты', status: AcceptPaymentStateStatus.paymentAuthorization));

    await iboxpro.apiLogin(
      login: login,
      password: password,
      onError: (String error) => emit(state.copyWith(message: error, status: AcceptPaymentStateStatus.failure)),
      onLogin: _startPayment
    );
  }

  Future<void> _startPayment() async {
    if (state.canceled) return;

    emit(state.copyWith(message: 'Ожидание ответа от терминала', status: AcceptPaymentStateStatus.waitingForPayment));

    await iboxpro.startPayment(
      amount: state.total,
      description: 'Оплата за заказ ${state.deliveryPointOrderEx.o.trackingNumber}',
      onError: (String error) => emit(state.copyWith(message: error, status: AcceptPaymentStateStatus.failure)),
      onPaymentStart: (_) {
        emit(state.copyWith(
          message: 'Обработка оплаты',
          status: AcceptPaymentStateStatus.waitingForPayment,
          isCancelable: false
        ));
      },
      onPaymentComplete: (Map<dynamic, dynamic> transaction, bool requiredSignature) {
        emit(state.copyWith(
          message: 'Подтверждение оплаты',
          status: AcceptPaymentStateStatus.paymentFinished,
          isRequiredSignature: requiredSignature
        ));

        if (!requiredSignature) {
          _savePayment(transaction);
        } else {
          emit(state.copyWith(
            message: 'Для завершения оплаты\nнеобходимо указать подпись',
            status: AcceptPaymentStateStatus.requiredSignature
          ));
        }
      }
    );
  }

  Future<void> adjustPayment(Uint8List signature) async {
    emit(state.copyWith(
      message: 'Сохранение подписи клиента',
      status: AcceptPaymentStateStatus.savingSignature,
      isRequiredSignature: false
    ));

    await iboxpro.adjustPayment(
      signature: signature,
      onError: (String error) => emit(state.copyWith(message: error, status: AcceptPaymentStateStatus.failure)),
      onPaymentAdjust: _savePayment
    );
  }

  Future<void> _savePayment([Map<dynamic, dynamic>? transaction]) async {
    emit(state.copyWith(message: 'Сохранение информации об оплате', status: AcceptPaymentStateStatus.savingPayment));

    try {
      await _acceptPayment(transaction);

      emit(state.copyWith(message: 'Оплата успешно сохранена', status: AcceptPaymentStateStatus.finished));
    } on AppError catch(e) {
      emit(state.copyWith(
        message: 'Ошибка при сохранении оплаты ${e.message}',
        status: AcceptPaymentStateStatus.failure
      ));
    }
  }

  Future<void> _acceptPayment(Map<dynamic, dynamic>? transaction) async {
    Location? location = await GeoLoc.getCurrentLocation();

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    try {
      await Api(storage: app.storage).acceptPayment(
        deliveryPointOrderId: state.deliveryPointOrderEx.dpo.id,
        summ: state.total,
        transaction: transaction,
        location: location
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.storage.paymentsDao.insertPayment(PaymentsCompanion(
      summ: Value(state.total),
      transactionId: Value(transaction?['id']),
      deliveryPointOrderId: Value(state.deliveryPointOrderEx.dpo.id)
    ));

    await app.storage.ordersDao.updateOrder(
      state.deliveryPointOrderEx.o.id,
      const OrdersCompanion(needPayment: Value(false))
    );
  }

  Future<ApiPaymentCredentials> _getApiPaymentCredentials() async {
    try {
      return await Api(storage: app.storage).getPaymentCredentials();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }
}
