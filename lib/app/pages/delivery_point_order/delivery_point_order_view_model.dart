part of 'delivery_point_order_page.dart';

class DeliveryPointOrderViewModel extends PageViewModel<DeliveryPointOrderState, DeliveryPointOrderStateStatus> {
  final DeliveriesRepository deliveriesRepository;
  final OrdersRepository ordersRepository;
  final PaymentsRepository paymentsRepository;
  final UsersRepository usersRepository;

  StreamSubscription<User>? userSubscription;
  StreamSubscription<List<DeliveryPointExResult>>? deliveryPointExListSubscription;
  StreamSubscription<List<OrderLine>>? orderLinesSubscription;
  StreamSubscription<List<OrderInfoLine>>? orderInfoLinesSubscription;
  StreamSubscription<List<DeliveryPointOrderExResult>>? deliveryPointOrderExListSubscrption;
  StreamSubscription<List<ExPayment>>? paymentsSubscription;

  DeliveryPointOrderViewModel(
    this.deliveriesRepository,
    this.ordersRepository,
    this.paymentsRepository,
    this.usersRepository,
    {
      required DeliveryPointOrderExResult deliveryPointOrderEx
    }
  ) :
    super(DeliveryPointOrderState(deliveryPointOrderEx: deliveryPointOrderEx, confirmationCallback: () {}));

  @override
  DeliveryPointOrderStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    userSubscription = usersRepository.watchUser().listen((event) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.dataLoaded, user: event));
    });
    deliveryPointExListSubscription = deliveriesRepository.watchExDeliveryPoints().listen((event) {
      emit(state.copyWith(
        status: DeliveryPointOrderStateStatus.dataLoaded,
        deliveryPointEx: event.firstWhereOrNull((el) => el.dp.id == state.deliveryPointOrderEx.dpo.deliveryPointId)
      ));
    });
    orderLinesSubscription = ordersRepository.watchOrderLines(state.deliveryPointOrderEx.o.id).listen((event) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.dataLoaded, orderLines: event));
    });
    orderInfoLinesSubscription = ordersRepository.watchOrderInfoLines(state.deliveryPointOrderEx.o.id).listen((event) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.dataLoaded, orderInfoLines: event));
    });
    deliveryPointOrderExListSubscrption = deliveriesRepository.watchExDeliveryPointOrders().listen((event) {
      emit(state.copyWith(
        status: DeliveryPointOrderStateStatus.dataLoaded,
        deliveryPointOrderEx: event.firstWhereOrNull((el) => el.dpo.id == state.deliveryPointOrderEx.dpo.id)
      ));
    });
    paymentsSubscription = paymentsRepository.watchPaymentsWithDPO().listen((event) {
      emit(state.copyWith(
        status: DeliveryPointOrderStateStatus.dataLoaded,
        exPayment: event.firstWhereOrNull((el) => el.deliveryPointOrderEx.dpo.id == state.deliveryPointOrderEx.dpo.id)
      ));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await userSubscription?.cancel();
    await deliveryPointExListSubscription?.cancel();
    await orderLinesSubscription?.cancel();
    await orderInfoLinesSubscription?.cancel();
    await deliveryPointOrderExListSubscrption?.cancel();
    await paymentsSubscription?.cancel();
  }

  Future<void> callPhone(String? phone) async {
    await Misc.callPhone(phone, onError: () => emit(state.copyWith(
      status: DeliveryPointOrderStateStatus.failure,
      message: Strings.genericErrorMsg
    )));
  }

  Future<void> updateOrderLineAmount(OrderLine orderLine, String amount) async {
    int? intAmount = int.tryParse(amount);

    await ordersRepository.updateOrderLine(
      orderLine,
      factAmount: intAmount
    );

    FLog.debug(text: intAmount.toString());
  }

  void tryStartPayment(bool cardPayment) {
    if (state.total == 0 || state.total < 0) {
      emit(state.copyWith(
        status: DeliveryPointOrderStateStatus.failure,
        message: 'Указана некорректная сумма'
      ));

      return;
    }

    emit(state.copyWith(
      status: DeliveryPointOrderStateStatus.needUserConfirmation,
      confirmationCallback: startPayment,
      message: 'Вы действительно хотите оплатить заказ ${cardPayment ? 'картой' : 'наличными'}?',
      cardPayment: cardPayment
    ));
  }

  Future<void> startPayment(bool confirmed) async {
    if (!confirmed) return;

    emit(state.copyWith(status: DeliveryPointOrderStateStatus.paymentStarted));
  }

  void finishPayment(String result) {
    emit(state.copyWith(status: DeliveryPointOrderStateStatus.paymentFinished, message: result));
  }

  void tryConfirmOrder() {
    List<String> messages = [];
    String typeMsgPart = state.isPickup ? 'забор' : 'доставку';

    if (!state.factsConfirmed && !state.isPickup) {
      emit(state.copyWith(
        status: DeliveryPointOrderStateStatus.failure,
        message: 'Не для всех позиций указан факт'
      ));

      return;
    }

    if (state.deliveryPointOrderEx.o.documentsReturn) messages.add('Вы забрали документы?');
    if (messages.isEmpty) messages.add('Вы действительно хотите завершить $typeMsgPart заказа?');

    emit(state.copyWith(
      status: DeliveryPointOrderStateStatus.needUserConfirmation,
      confirmationCallback: confirmOrder,
      message: messages.join('\n')
    ));
  }

  Future<void> confirmOrderFacts() async {
    emit(state.copyWith(status: DeliveryPointOrderStateStatus.inProgress));

    try {
      for (var orderLine in state.orderLines.where((el) => el.factAmount == null)) {
        await ordersRepository.updateOrderLine(orderLine, factAmount: orderLine.amount);
      }

      await deliveriesRepository.confirmOrderFacts(
        deliveryPointOrderEx: state.deliveryPointOrderEx,
        orderLines: await ordersRepository.watchOrderLines(state.deliveryPointOrderEx.o.id).first
      );

      emit(state.copyWith(
        status: DeliveryPointOrderStateStatus.confirmed,
        message: 'Факты позиций подтверждены'
      ));

      if (!state.isPickup && state.exPayment == null && state.total != 0) {
        emit(state.copyWith(status: DeliveryPointOrderStateStatus.askPaymentCollection));
      }
    } on AppError catch(e) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.failure, message: e.message));
    }
  }

  Future<void> confirmOrder(bool confirmed) async {
    if (!confirmed) {
      if (state.deliveryPointOrderEx.o.documentsReturn) {
        emit(state.copyWith(
          status: DeliveryPointOrderStateStatus.failure,
          message: 'Нельзя завершить заказ без возврата документов'
        ));

        return;
      }

      emit(state.copyWith(status: DeliveryPointOrderStateStatus.failure, message: 'Заказ не подтвержден'));
      return;
    }

    emit(state.copyWith(status: DeliveryPointOrderStateStatus.inProgress));

    try {
      await deliveriesRepository.confirmOrder(
        deliveryPointOrderEx: state.deliveryPointOrderEx,
        isPickup: state.isPickup,
        location: (await GeoLoc.getCurrentLocation())!,
        user: state.user!,
      );

      emit(state.copyWith(
        status: DeliveryPointOrderStateStatus.confirmed,
        message: state.isPickup ? 'Забор заказа завершен' : 'Доставка заказа завершена'
      ));
    } on AppError catch(e) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.failure, message: e.message));
    }
  }

  void tryCancelOrder() {
    emit(state.copyWith(
      status: DeliveryPointOrderStateStatus.needUserConfirmation,
      confirmationCallback: cancelOrder,
      message: 'Вы действительно хотите отменить заказ?'
    ));
  }

  Future<void> cancelOrder(bool confirmed) async {
    if (!confirmed) return;

    emit(state.copyWith(status: DeliveryPointOrderStateStatus.inProgress));

    try {
      await deliveriesRepository.cancelOrder(
        deliveryPointOrderEx: state.deliveryPointOrderEx,
        location: (await GeoLoc.getCurrentLocation())!,
      );
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.canceled, message: 'Заказ отменен'));
    } on AppError catch(e) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.failure, message: e.message));
    }
  }

  Future<void> addComment(String comment) async {
    emit(state.copyWith(status: DeliveryPointOrderStateStatus.inProgress));

    try {
      await deliveriesRepository.addOrderInfo(deliveryPointOrderEx: state.deliveryPointOrderEx, comment: comment);
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.commentAdded, message: 'Комментарий добавлен'));
    } on AppError catch(e) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.failure, message: e.message));
    }
  }
}
