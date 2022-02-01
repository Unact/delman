part of 'payments_page.dart';

class PaymentsViewModel extends PageViewModel<PaymentsState, PaymentsStateStatus> {
  PaymentsViewModel(BuildContext context) : super(context, PaymentsState());

  @override
  PaymentsStateStatus get status => state.status;

  @override
  TableUpdateQuery get listenForTables => TableUpdateQuery.onAllTables([
    app.storage.payments,
    app.storage.deliveryPointOrders,
    app.storage.orders
  ]);

  @override
  Future<void> loadData() async {
    emit(state.copyWith(
      status: PaymentsStateStatus.dataLoaded,
      exPayments: await app.storage.paymentsDao.getPaymentsWithDPO()
    ));
  }
}
