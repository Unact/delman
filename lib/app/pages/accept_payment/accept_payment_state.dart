part of 'accept_payment_page.dart';

abstract class AcceptPaymentState {
  final String message;

  const AcceptPaymentState(this.message);
}

class AcceptPaymentInitial extends AcceptPaymentState {
  AcceptPaymentInitial(String message) : super(message);
}

class AcceptPaymentSearchingForDevice extends AcceptPaymentState {
  AcceptPaymentSearchingForDevice(String message) : super(message);
}

class AcceptPaymentGettingCredentials extends AcceptPaymentState {
  AcceptPaymentGettingCredentials(String message) : super(message);
}

class AcceptPaymentPaymentAuthorization extends AcceptPaymentState {
  AcceptPaymentPaymentAuthorization(String message) : super(message);
}

class AcceptPaymentWaitingForPayment extends AcceptPaymentState {
  AcceptPaymentWaitingForPayment(String message) : super(message);
}

class AcceptPaymentPaymentStarted extends AcceptPaymentState {
  AcceptPaymentPaymentStarted(String message) : super(message);
}

class AcceptPaymentPaymentFinished extends AcceptPaymentState {
  AcceptPaymentPaymentFinished(String message) : super(message);
}

class AcceptPaymentRequiredSignature extends AcceptPaymentState {
  AcceptPaymentRequiredSignature(String message) : super(message);
}

class AcceptPaymentSavingSignature extends AcceptPaymentState {
  AcceptPaymentSavingSignature(String message) : super(message);
}

class AcceptPaymentSavingPayment extends AcceptPaymentState {
  AcceptPaymentSavingPayment(String message) : super(message);
}

class AcceptPaymentFinished extends AcceptPaymentState {
  AcceptPaymentFinished(String message) : super(message);
}

class AcceptPaymentFailure extends AcceptPaymentState {
  AcceptPaymentFailure(String message) : super(message);
}
