import 'package:flutter/material.dart';

import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/view_models/base_view_model.dart';

class OrderStoragesViewModel extends BaseViewModel {
  OrderStoragesViewModel({required BuildContext context}) : super(context: context);

  List<OrderStorage> get orderStorages {
    return appState.orderStorages.where((e) => e.id != appState.user.storageId).toList();
  }
}
