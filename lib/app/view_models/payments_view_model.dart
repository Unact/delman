import 'package:flutter/material.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/view_models/base_view_model.dart';

class PaymentsViewModel extends BaseViewModel {
  PaymentsViewModel({@required BuildContext context}) : super(context: context);

  Delivery get delivery => appState.deliveries.firstWhere((e) => e.isActive);
  List<Payment> get payments {
    return appState.payments..sort((a, b) => a.summ.compareTo(b.summ));
  }

  Order getOrderForPayment(Payment payment) {
    return appState.orders.firstWhere((e) => e.deliveryPointOrderId == payment.deliveryPointOrderId);
  }
}
