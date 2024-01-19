part of 'payments_page.dart';

class PaymentsViewModel extends PageViewModel<PaymentsState, PaymentsStateStatus> {
  final PaymentsRepository paymentsRepository;

  StreamSubscription<List<ExPayment>>? exPaymentsSubscription;

  PaymentsViewModel(this.paymentsRepository) : super(PaymentsState());

  @override
  PaymentsStateStatus get status => state.status;

  @override
  Future<void> initViewModel() async {
    await super.initViewModel();

    exPaymentsSubscription = paymentsRepository.watchPaymentsWithDPO().listen((event) {
      emit(state.copyWith(status: PaymentsStateStatus.dataLoaded, exPayments: event));
    });
  }

  @override
  Future<void> close() async {
    await super.close();

    await exPaymentsSubscription?.cancel();
  }
}
