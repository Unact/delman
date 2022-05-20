part of 'order_qr_scan_page.dart';

class OrderQRScanViewModel extends PageViewModel<OrderQRScanState, OrderQRScanStateStatus> {
  OrderQRScanViewModel(BuildContext context) : super(context, OrderQRScanState());

  @override
  OrderQRScanStateStatus get status => state.status;

  @override
  Future<void> loadData() async {}

  Future<void> readQRCode(String? qrCode) async {
    if (qrCode == null) return;

    emit(state.copyWith(status: OrderQRScanStateStatus.scanReadStarted));

    List<String> qrCodeData = qrCode.split(' ');
    OrderQRScanState newState = state;
    List<bool> newOrderPackageScanned = state.orderPackageScanned;

    if (qrCodeData.length < 3 || qrCodeData[0] != Strings.qrCodeVersion) {
      emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: 'Считан не поддерживаемый QR код'));
      return;
    }

    String qrTrackingNumber = qrCodeData[1];
    int packageNumber = int.tryParse(qrCodeData[2]) ?? 1;

    if (state.order != null) {
      if (qrTrackingNumber != state.order!.trackingNumber) {
        emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: 'Считан QR код другого заказа'));
        return;
      }

      if (state.orderPackageScanned[packageNumber - 1]) {
        emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: 'QR код уже был считан'));
        return;
      }
    } else {
      try {
        Order? order = await _findOrder(qrTrackingNumber);

        if (order == null) {
          emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: 'Не удалось найти заказ'));
          return;
        }

        newState = state.copyWith(order: order);
        newOrderPackageScanned = List.filled(order.packages, false);
      } on AppError catch(e) {
        emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: e.message));
        return;
      }
    }

    newOrderPackageScanned[packageNumber - 1] = true;
    OrderQRScanStateStatus newStatus = newOrderPackageScanned.contains(false) ?
      OrderQRScanStateStatus.scanReadFinished :
      OrderQRScanStateStatus.finished;

    emit(newState.copyWith(orderPackageScanned: newOrderPackageScanned, status: newStatus));
  }

  Future<Order?> _findOrder(String trackingNumber) async {
    try {
      Order? order = await app.storage.ordersDao.getOrderByTrackingNumber(trackingNumber);
      if (order != null) return order;

      ApiFindOrderData? data = await Api(storage: app.storage).findOrderData(trackingNumber: trackingNumber);

      if (data != null) {
        order = data.order.toDatabaseEnt();

        await app.storage.transaction(() async {
          await app.storage.ordersDao.insertOrder(order!.toCompanion(false));
          await Future.forEach<OrderLinesCompanion>(
            data.orderLines.map((e) =>e.toDatabaseEnt().toCompanion(false)),
            (e) => app.storage.ordersDao.insertOrderLine(e)
          );
          await Future.forEach<OrderInfoLinesCompanion>(
            data.orderInfoList.map((e) =>e.toDatabaseEnt().toCompanion(false)),
            (e) => app.storage.ordersDao.insertOrderInfoLine(e)
          );
        });

        return order;
      }

      return null;
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      await app.reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }
}
