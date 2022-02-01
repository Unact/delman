import 'package:flutter/material.dart';

import '/app/data/database.dart';

class Styling {
  static deliveryPointColor(DeliveryPointExResult deliveryPointEx) {
    if (deliveryPointEx.isCompleted) return Colors.green[400]!;
    if (deliveryPointEx.isIncomplete) return Colors.purple[400]!;
    if (deliveryPointEx.isInProgress) return Colors.yellow[400]!;

    return Colors.blue[400]!;
  }
}
