part of 'order_qr_scan_page.dart';

abstract class OrderQRScanState {
  OrderQRScanState();
}

class OrderQRScanInitial extends OrderQRScanState {}

class OrderQRScanReadFinished extends OrderQRScanState {}

class OrderQRScanFailure extends OrderQRScanState {
  final String message;

  OrderQRScanFailure(this.message);
}

class OrderQRScanFinished extends OrderQRScanState {}
