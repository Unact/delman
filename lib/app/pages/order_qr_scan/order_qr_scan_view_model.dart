part of 'order_qr_scan_page.dart';

class OrderQRScanViewModel extends PageViewModel<OrderQRScanState, OrderQRScanStateStatus> {
  final OrdersRepository ordersRepository;
  static const String qrType = 'ORDER';

  OrderQRScanViewModel(this.ordersRepository) : super(OrderQRScanState());

  @override
  OrderQRScanStateStatus get status => state.status;

  Future<void> readQRCode(String? qrCode) async {
    if (qrCode == null) return;

    emit(state.copyWith(status: OrderQRScanStateStatus.scanReadStarted));

    List<String> qrCodeData = qrCode.split(' ');

    switch (qrCodeData[0]) {
      case Strings.oldQRCodeVersion:
        return await _processQR(qrCodeData[1], int.parse(qrCodeData[2]));
      case Strings.newQRCodeVersion:
        if (qrCodeData[3] != qrType) {
          emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: 'QR код не от заказа'));
          return;
        }

        return await _processQR(qrCodeData[4], int.parse(qrCodeData[5]));
      default:
        emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: 'Считан не поддерживаемый QR код'));
        return;
    }
  }

  Future<void> _processQR(String qrTrackingNumber, int packageNumber) async {
    OrderQRScanState newState = state;
    List<bool> newOrderPackageScanned = state.orderPackageScanned;

    if (state.order != null) {
      if (qrTrackingNumber != state.order!.trackingNumber) {
        emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: 'QR код другого заказа'));
        return;
      }

      if (state.orderPackageScanned[packageNumber - 1]) {
        emit(state.copyWith(status: OrderQRScanStateStatus.failure, message: 'QR код уже был считан'));
        return;
      }
    } else {
      try {
        Order? order = await ordersRepository.findOrder(qrTrackingNumber);

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
}
