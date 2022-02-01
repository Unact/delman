part of 'payments_page.dart';

enum PaymentsStateStatus {
  initial,
  dataLoaded
}

class PaymentsState {
  PaymentsState({
    this.status = PaymentsStateStatus.initial,
    this.exPayments = const []
  });

  final List<ExPayment> exPayments;
  final PaymentsStateStatus status;

  PaymentsState copyWith({
    PaymentsStateStatus? status,
    List<ExPayment>? exPayments
  }) {
    return PaymentsState(
      status: status ?? this.status,
      exPayments: exPayments ?? this.exPayments
    );
  }
}
