
part of 'info_page.dart';

enum InfoStateStatus {
  initial,
  dataLoaded,
  startLoad,
  closeInProgress,
  closeSuccess,
  closeFailure
}

class InfoState {
  InfoState({
    this.status = InfoStateStatus.initial,
    this.deliveries = const [],
    this.user,
    this.appInfo,
    this.message = ''
  });

  final List<ExDelivery> deliveries;
  final InfoStateStatus status;
  final String message;
  final User? user;
  final AppInfoResult? appInfo;

  int get deliveryPointsCnt => deliveries.map((el) => el.deliveryPoints.length).fold(0, (prev, el) => prev + el);
  int get deliveryPointsLeftCnt => deliveries
    .map((el) => el.deliveryPoints)
    .expand((el) => el)
    .where((el) => !el.isCompleted).length;
  int get ordersInOwnStorageCnt => appInfo?.ownOrders ?? 0;
  int get ordersNotInOwnStorageCnt => appInfo?.needTransferOrders ?? 0;

  int get paymentsCnt =>  cashPaymentsCnt + cardPaymentsCnt;
  int get cashPaymentsCnt => appInfo?.cashPaymentsTotal ?? 0;
  int get cardPaymentsCnt => appInfo?.cardPaymentsTotal ?? 0;
  double get paymentsSum => cashPaymentsSum + cardPaymentsSum;
  double get cashPaymentsSum => appInfo?.cashPaymentsSum ?? 0;
  double get cardPaymentsSum => appInfo?.cardPaymentsSum ?? 0;

  InfoState copyWith({
    InfoStateStatus? status,
    List<ExDelivery>? deliveries,
    String? message,
    User? user,
    AppInfoResult? appInfo,
  }) {
    return InfoState(
      status: status ?? this.status,
      deliveries: deliveries ?? this.deliveries,
      message: message ?? this.message,
      user: user ?? this.user,
      appInfo: appInfo ?? this.appInfo,
    );
  }
}
