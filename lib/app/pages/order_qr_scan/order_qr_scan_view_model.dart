part of 'order_qr_scan_page.dart';

class OrderQRScanViewModel extends PageViewModel<OrderQRScanState> {
  Order? currentOrder;
  List<bool>? orderPackageScanned;

  OrderQRScanViewModel(BuildContext context) : super(context, OrderQRScanInitial());

  Future<void> readQRCode(String? qrCode) async {
    if (qrCode == null) return;

    List<String> qrCodeData = qrCode.split(' ');

    if (qrCodeData.length < 3 || qrCodeData[0] != Strings.qrCodeVersion) {
      emit(OrderQRScanFailure('Считан не поддерживаемый QR код'));
      return;
    }

    String qrTrackingNumber = qrCodeData[1];
    int packageNumber = int.tryParse(qrCodeData[2]) ?? 1;

    if (currentOrder != null) {
      if (qrTrackingNumber != currentOrder!.trackingNumber) {
        emit(OrderQRScanFailure('Считан QR код другого заказа'));
        return;
      }

      if (orderPackageScanned![packageNumber - 1]) {
        emit(OrderQRScanFailure('QR код уже был считан'));
        return;
      }
    } else {
      currentOrder = appViewModel.orders.firstWhereOrNull((e) => e.trackingNumber == qrTrackingNumber);

      if (currentOrder == null) {
        emit(OrderQRScanFailure('Не удалось найти заказ'));
        return;
      }

      orderPackageScanned = List.filled(currentOrder!.packages, false);
    }

    orderPackageScanned![packageNumber - 1] = true;

    if (orderPackageScanned!.contains(false)) {
      emit(OrderQRScanReadFinished());
    } else {
      emit(OrderQRScanFinished());
    }
  }
}
