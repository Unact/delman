part of 'accept_payment_page.dart';

class AcceptPaymentViewModel extends PageViewModel<AcceptPaymentState, AcceptPaymentStateStatus> {
  final AppRepository appRepository;
  final PaymentsRepository paymentsRepository;
  late Iboxpro iboxpro = Iboxpro(
    onError: (String error) => emit(state.copyWith(message: error, status: AcceptPaymentStateStatus.failure)),
    onLogin: _startPayment,
    onConnected: _getPaymentCredentials,
    onStart: (String id) {
      emit(state.copyWith(
        isCancelable: true,
        message: 'Обработка оплаты',
        status: AcceptPaymentStateStatus.paymentStarted
      ));
    },
    onComplete: (Map<String, dynamic> transaction, bool requiredSignature) {
      emit(state.copyWith(
        transaction: transaction,
        isRequiredSignature: requiredSignature,
        message: 'Подтверждение оплаты',
        status: AcceptPaymentStateStatus.paymentFinished
      ));

      if (!requiredSignature) {
        _savePayment();
      } else {
        emit(state.copyWith(
          message: 'Для завершения оплаты\nнеобходимо указать подпись',
          status: AcceptPaymentStateStatus.requiredSignature
        ));
      }
    },
    onAdjust: _savePayment
  );

  AcceptPaymentViewModel(
    this.appRepository,
    this.paymentsRepository,
    {
      required double total,
      required bool cardPayment,
      required DeliveryPointOrderExResult deliveryPointOrderEx
    }
  ) :
    super(AcceptPaymentState(
      message: 'Инициализация платежа',
      total: total,
      cardPayment: cardPayment,
      deliveryPointOrderEx: deliveryPointOrderEx
    ));

  @override
  AcceptPaymentStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    super.initViewModel();

    _getLocation();
  }

  @override
  Future<void> close() async {
    iboxpro.dispose();
    super.close();
  }

  Future<void> _getLocation() async {
    emit(state.copyWith(position: await Geolocator.getCurrentPosition()));

    if (!state.cardPayment) {
      _savePayment();
      return;
    }

    _connectToDevice();
  }

  Future<void> cancelPayment() async {
    await iboxpro.cancelPayment();

    emit(state.copyWith(message: 'Платеж отменен', canceled: true, status: AcceptPaymentStateStatus.failure));
  }

  Future<void> _connectToDevice() async {
    if (!await Permissions.hasBluetoothPermission()) {
      emit(state.copyWith(message: 'Не разрешено соединение по Bluetooth', status: AcceptPaymentStateStatus.failure));
      return;
    }

    emit(state.copyWith(
      message: 'Установление связи с терминалом',
      status: AcceptPaymentStateStatus.searchingForDevice
    ));

    iboxpro.connectToDevice();
  }

  Future<void> _getPaymentCredentials([String? _]) async {
    if (state.canceled) return;

    emit(state.copyWith(message: 'Установление связи с сервером', status: AcceptPaymentStateStatus.gettingCredentials));

    try {
      ApiPaymentCredentials credentials = await appRepository.getApiPaymentCredentials();

      await _apiLogin(credentials.login, credentials.password);
    } on AppError catch(e) {
      emit(state.copyWith(message: e.message, status: AcceptPaymentStateStatus.failure));
    }
  }

  Future<void> _apiLogin(String login, String password) async {
    if (state.canceled) return;

    emit(state.copyWith(message: 'Авторизация оплаты', status: AcceptPaymentStateStatus.paymentAuthorization));

    await iboxpro.apiLogin(login: login, password: password);
  }

  Future<void> _startPayment() async {
    if (state.canceled) return;

    emit(state.copyWith(message: 'Ожидание ответа от терминала', status: AcceptPaymentStateStatus.waitingForPayment));

    await iboxpro.startPayment(
      amount: state.total,
      description: 'Оплата за заказ ${state.deliveryPointOrderEx.o.trackingNumber}',
      isLink: false
    );
  }

  Future<void> adjustPayment(Uint8List signature) async {
    emit(state.copyWith(
      message: 'Сохранение подписи клиента',
      status: AcceptPaymentStateStatus.savingSignature,
      isRequiredSignature: false
    ));

    await iboxpro.adjustPayment(signature: signature);
  }

  Future<void> _savePayment() async {
    emit(state.copyWith(message: 'Сохранение информации об оплате', status: AcceptPaymentStateStatus.savingPayment));

    try {
      await paymentsRepository.acceptPayment(
        transaction: state.transaction,
        position: state.position!,
        summ: state.total,
        deliveryPointOrderEx: state.deliveryPointOrderEx
      );

      emit(state.copyWith(message: 'Оплата успешно сохранена', status: AcceptPaymentStateStatus.finished));
    } on AppError catch(e) {
      emit(state.copyWith(
        message: 'Ошибка при сохранении оплаты ${e.message}',
        status: AcceptPaymentStateStatus.failure
      ));
    }
  }
}
