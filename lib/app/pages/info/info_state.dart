
part of 'info_page.dart';

enum InfoStateStatus {
  initial,
  dataLoaded,
  startLoad,
  inCloseProgress,
  closeSuccess,
  closeFailure,
  inLoadProgress,
  loadSuccess,
  loadFailure
}

class InfoState {
  InfoState({
    this.status = InfoStateStatus.initial,
    this.cashPayments = const [],
    this.cardPayments = const [],
    this.deliveries = const [],
    this.orders = const [],
    this.newVersionAvailable = false,
    this.message = ''
  });

  final List<Payment> cashPayments;
  final List<Payment> cardPayments;
  final List<ExDelivery> deliveries;
  final List<OrderWithTransferResult> orders;
  final bool newVersionAvailable;
  final InfoStateStatus status;
  final String message;

  bool get isBusy => [
    InfoStateStatus.inLoadProgress,
    InfoStateStatus.inCloseProgress
  ].contains(status);

  int get deliveryPointsCnt => deliveries.map((el) => el.deliveryPoints.length).fold(0, (prev, el) => prev + el);
  int get deliveryPointsLeftCnt => deliveries
    .map((el) => el.deliveryPoints)
    .expand((el) => el)
    .where((el) => !el.isCompleted).length;
  int get ordersInOwnStorageCnt => orders.where((el) => el.own).length;
  int get ordersNotInOwnStorageCnt => orders.where((el) => el.needTransfer).length;

  int get paymentsCnt => cashPaymentsCnt + cardPaymentsCnt;
  int get cashPaymentsCnt => cashPayments.length;
  int get cardPaymentsCnt => cardPayments.length;
  double get paymentsSum => cashPaymentsSum + cardPaymentsSum;
  double get cashPaymentsSum => cashPayments.fold(0, (prev, el) => prev + el.summ);
  double get cardPaymentsSum => cardPayments.fold(0, (prev, el) => prev + el.summ);

  InfoState copyWith({
    InfoStateStatus? status,
    List<Payment>? cashPayments,
    List<Payment>? cardPayments,
    List<ExDelivery>? deliveries,
    List<OrderWithTransferResult>? orders,
    bool? newVersionAvailable,
    String? message
  }) {
    return InfoState(
      status: status ?? this.status,
      cashPayments: cashPayments ?? this.cashPayments,
      cardPayments: cardPayments ?? this.cardPayments,
      deliveries: deliveries ?? this.deliveries,
      orders: orders ?? this.orders,
      newVersionAvailable: newVersionAvailable ?? this.newVersionAvailable,
      message: message ?? this.message
    );
  }
}
