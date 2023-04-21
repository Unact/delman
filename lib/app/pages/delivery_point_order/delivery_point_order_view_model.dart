part of 'delivery_point_order_page.dart';

class DeliveryPointOrderViewModel extends PageViewModel<DeliveryPointOrderState, DeliveryPointOrderStateStatus> {
  DeliveryPointOrderViewModel(BuildContext context, { required DeliveryPointOrderExResult deliveryPointOrderEx}) :
    super(context, DeliveryPointOrderState(deliveryPointOrderEx: deliveryPointOrderEx, confirmationCallback: () {}));

  @override
  DeliveryPointOrderStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.orders,
    app.storage.orderInfoLines,
    app.storage.orderLines,
    app.storage.deliveryPointOrders,
    app.storage.deliveryPoints,
    app.storage.payments,
    app.storage.users
  ]);

  @override
  Future<void> loadData() async {
    List<OrderLine> orderLines = (await app.storage.ordersDao.getOrderLines(state.deliveryPointOrderEx.o.id))
      .map((e) => e.factAmount != null ? e : e.copyWith(factAmount: e.factAmount ?? e.amount))
      .toList();

    emit(state.copyWith(
      status: DeliveryPointOrderStateStatus.dataLoaded,
      user: await app.storage.usersDao.getUser(),
      deliveryPointOrderEx: await app.storage.deliveriesDao.getExDeliveryPointOrder(state.deliveryPointOrderEx.dpo.id),
      orderInfoLines: await app.storage.ordersDao.getOrderInfoLines(state.deliveryPointOrderEx.o.id),
      orderLines: orderLines,
      deliveryPointEx: await app.storage.deliveriesDao.getExDeliveryPoint(
        state.deliveryPointOrderEx.dpo.deliveryPointId
      ),
      payment: await app.storage.paymentsDao.getPaymentForDPO(state.deliveryPointOrderEx.dpo.id)
    ));
  }

  Future<void> callPhone(String? phone) async {
    await Misc.callPhone(phone, onFailure: () => emit(state.copyWith(
      status: DeliveryPointOrderStateStatus.failure,
      message: Strings.genericErrorMsg
    )));
  }

  Future<void> updateOrderLineAmount(OrderLine orderLine, String amount) async {
    int? intAmount = int.tryParse(amount);

    await app.storage.ordersDao.updateOrderLine(
      orderLine.id,
      OrderLinesCompanion(factAmount: Value(intAmount))
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

    if (!state.factsConfirmed) {
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
      await _confirmOrderFacts();

      await app.storage.ordersDao.updateOrder(
        state.deliveryPointOrderEx.o.id,
        const OrdersCompanion(factsConfirmed: Value(true))
      );

      emit(state.copyWith(
        status: DeliveryPointOrderStateStatus.confirmed,
        message: 'Факты позиций подтверждены'
      ));

      if (!state.isPickup && state.payment == null && state.total != 0) {
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
      await _confirmOrder();

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
      await _cancelOrder();
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.canceled, message: 'Заказ отменен'));
    } on AppError catch(e) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.failure, message: e.message));
    }
  }

  Future<void> addComment(String comment) async {
    emit(state.copyWith(status: DeliveryPointOrderStateStatus.inProgress));

    try {
      await _addOrderInfo(comment);
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.commentAdded, message: 'Комментарий добавлен'));
    } on AppError catch(e) {
      emit(state.copyWith(status: DeliveryPointOrderStateStatus.failure, message: e.message));
    }
  }

  Future<void> _cancelOrder() async {
    Location? location = await GeoLoc.getCurrentLocation();

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    try {
      await Api(storage: app.storage).cancelOrder(
        deliveryPointOrderId: state.deliveryPointOrderEx.dpo.id,
        location: location
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.storage.deliveriesDao.updateDeliveryPointOrder(
      state.deliveryPointOrderEx.dpo.id,
      const DeliveryPointOrdersCompanion(canceled: Value(true), finished: Value(true))
    );

    await _departFromDeliveryPoint();
  }

  Future<void> _confirmOrderFacts() async {
    try {
      await Api(storage: app.storage).confirmOrderFacts(
        deliveryPointOrderId: state.deliveryPointOrderEx.dpo.id,
        orderLines: state.orderLines.map((e) => {'id': e.id, 'factAmount': e.factAmount}).toList(),
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> _confirmOrder() async {
    Location? location = await GeoLoc.getCurrentLocation();

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    try {
      await Api(storage: app.storage).confirmOrder(
        deliveryPointOrderId: state.deliveryPointOrderEx.dpo.id,
        location: location
      );
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.storage.ordersDao.updateOrder(
      state.deliveryPointOrderEx.o.id,
      OrdersCompanion(storageId: Value(state.isPickup ? state.user?.storageId : null))
    );

    await app.storage.deliveriesDao.updateDeliveryPointOrder(
      state.deliveryPointOrderEx.dpo.id,
      const DeliveryPointOrdersCompanion(finished: Value(true))
    );

    await _departFromDeliveryPoint();
  }

  Future<void> _addOrderInfo(String comment) async {
    try {
      await Api(storage: app.storage).addOrderInfo(orderId: state.deliveryPointOrderEx.o.id, comment: comment);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await app.storage.ordersDao.insertOrderInfoLine(OrderInfoLinesCompanion(
      orderId: Value(state.deliveryPointOrderEx.o.id),
      comment: Value(comment),
      ts: Value(DateTime.now())
    ));
  }

  Future<void> _departFromDeliveryPoint() async {
    List<DeliveryPointOrderExResult> deliveryOrderPointsEx = await app.storage.deliveriesDao.getExDeliveryPointOrders(
      state.deliveryPointOrderEx.dpo.deliveryPointId
    );

    if (deliveryOrderPointsEx.any((e) => !e.dpo.finished)) return;

    await app.storage.deliveriesDao.updateDeliveryPoint(
      state.deliveryPointOrderEx.dpo.deliveryPointId,
      DeliveryPointsCompanion(factDeparture: Value(DateTime.now()))
    );
  }
}
