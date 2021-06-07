import 'package:flutter/material.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/view_models/base_view_model.dart';

class PaymentsViewModel extends BaseViewModel {
  PaymentsViewModel({required BuildContext context}) : super(context: context);

  List<Payment> get payments {
    return appState.payments..sort((a, b) => a.summ.compareTo(b.summ));
  }

  Order getOrderForPayment(Payment payment) {
    return appState.orders.firstWhere((e) => e.id == payment.deliveryPointOrderId);
  }

  DeliveryPoint getDeliveryPointForPayment(Payment payment) {
    Order order = getOrderForPayment(payment);

    return appState.deliveryPoints.firstWhere((e) => e.id == order.deliveryPointId);
  }
}
