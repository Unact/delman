part of 'order_qr_scan_page.dart';

enum OrderQRScanStateStatus {
  initial,
  scanReadFinished,
  failure,
  finished
}

class OrderQRScanState {
  OrderQRScanState({
    this.status = OrderQRScanStateStatus.initial,
    this.order,
    this.orderPackageScanned = const [],
    this.message = ''
  });

  final OrderQRScanStateStatus status;
  final String message;
  final Order? order;
  final List<bool> orderPackageScanned;

  OrderQRScanState copyWith({
    OrderQRScanStateStatus? status,
    Order? order,
    List<bool>? orderPackageScanned,
    String? message
  }) {
    return OrderQRScanState(
      status: status ?? this.status,
      order: order ?? this.order,
      orderPackageScanned: orderPackageScanned ?? this.orderPackageScanned,
      message: message ?? this.message
    );
  }
}
