part of 'payments_page.dart';

class PaymentsViewModel extends PageViewModel<PaymentsState> {
  PaymentsViewModel(BuildContext context) : super(context, PaymentsInitial());

  List<Payment> get payments {
    return appViewModel.payments..sort((a, b) => a.summ.compareTo(b.summ));
  }

  Order getOrderForPayment(Payment payment) {
    DeliveryPointOrder deliveryPointOrder = getDeliveryPointOrderForPayment(payment);

    return appViewModel.orders.firstWhere((e) => e.id == deliveryPointOrder.orderId);
  }

  DeliveryPointOrder getDeliveryPointOrderForPayment(Payment payment) {
    return appViewModel.deliveryPointOrders.firstWhere((e) => e.id == payment.deliveryPointOrderId);
  }
}
