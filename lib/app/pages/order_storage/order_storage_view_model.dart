part of 'order_storage_page.dart';

class OrderStorageViewModel extends PageViewModel<OrderStorageState> {
  OrderStorage orderStorage;

  OrderStorageViewModel(BuildContext context, {required this.orderStorage}) : super(context, OrderStorageInitial());

  List<Order> get ordersInOwnStorage {
    return appViewModel.orders
      .where((e) => e.storageId == appViewModel.user.storageId).toList()
      ..sort((a, b) => a.trackingNumber.compareTo(b.trackingNumber));
  }

  List<Order> get ordersInOrderStorage {
    return appViewModel.orders
      .where((e) => e.storageId == orderStorage.id)
      .toList()
      ..sort((a, b) => a.trackingNumber.compareTo(b.trackingNumber));
  }

  Future<void> startQRScan() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isPermanentlyDenied || status.isDenied) {
      emit(OrderStorageFailure('Для сканирования QR кода необходимо разрешить использование камеры'));
      return;
    }

    emit(OrderStorageStartedQRScan());
  }

  Order? orderFromManualInput(String trackingNumber, String packageNumberStr) {
    int packageNumber = int.tryParse(packageNumberStr) ?? 1;

    Order? order = appViewModel.orders.firstWhereOrNull((e) => e.trackingNumber == trackingNumber);

    if (order == null) {
      emit(OrderStorageFailure('Не удалось найти заказ'));
      return null;
    }

    if (order.packages != packageNumber) {
      emit(OrderStorageFailure('Указанное кол-во мест не совпадает с кол-вом мест заказа'));
      return null;
    }

    return order;
  }

  Future<void> tryMoveOrder(Order order) async {
    if (order.storageId == appViewModel.user.storageId) {
      await transferOrder(order);
    } else {
      await tryAcceptOrder(order);
    }
  }

  Future<void> tryAcceptOrder(Order order) async {
    if (order.needDocumentsReturn) {
      emit(OrderStorageNeedUserConfirmation(
        'Вы забрали документы?',
        (bool confirmed) async {
          if (!confirmed) {
            emit(OrderStorageFailure('Нельзя принять заказ без возврата документов'));
            return;
          }

          await acceptOrder(order);
        }
      ));

      return;
    }

    await acceptOrder(order);
  }

  Future<void> acceptOrder(Order order) async {
    emit(OrderStorageInProgress());

    try {
      await appViewModel.acceptOrder(order);
      emit(OrderStorageAccepted('Заказ успешно принят'));
    } on AppError catch(e) {
      emit(OrderStorageFailure(e.message));
    }
  }

  Future<void> transferOrder(Order order) async {
    emit(OrderStorageInProgress());

    try {
      await appViewModel.transferOrder(order, orderStorage);
      emit(OrderStorageTransferred('Заказ успешно передан в ${orderStorage.name}'));
    } on AppError catch(e) {
      emit(OrderStorageFailure(e.message));
    }
  }
}
