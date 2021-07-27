import 'package:flutter/material.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/view_models/base_view_model.dart';

class DeliveryViewModel extends BaseViewModel {
  DeliveryViewModel({required BuildContext context}) : super(context: context);

  List<Delivery> get deliveries => appState.deliveries..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));
  List<DeliveryPoint> getDeliveryPointsForDelivery(Delivery delivery) {
    return appState.deliveryPoints
      .where((e) => e.deliveryId == delivery.id)
      .toList()
      ..sort((a, b) => a.seq.compareTo(b.seq));
  }
}
