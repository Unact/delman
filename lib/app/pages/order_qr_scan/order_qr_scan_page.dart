import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/pages/shared/page_view_model.dart';

part 'order_qr_scan_state.dart';
part 'order_qr_scan_view_model.dart';

class OrderQRScanPage extends StatelessWidget {
  OrderQRScanPage({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OrderQRScanViewModel>(
      create: (context) => OrderQRScanViewModel(context),
      child: _OrderQRScanView(),
    );
  }
}

class _OrderQRScanView extends StatefulWidget {
  @override
  _OrderQRScanViewState createState() => _OrderQRScanViewState();
}

class _OrderQRScanViewState extends State<_OrderQRScanView> {
  final GlobalKey _qrKey = GlobalKey();
  QRViewController? _controller;
  StreamSubscription? _subscription;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller!.pauseCamera();
    } else if (Platform.isIOS) {
      _controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OrderQRScanViewModel, OrderQRScanState>(
      builder: (context, state) {
        OrderQRScanViewModel vm = context.read<OrderQRScanViewModel>();

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            actions: <Widget>[
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.flash_on),
                onPressed: () async {
                  _controller!.toggleFlash();
                }
              ),
              IconButton(
                color: Colors.white,
                icon: const Icon(Icons.switch_camera),
                onPressed: () async {
                  _controller!.flipCamera();
                }
              )
            ],
          ),
          extendBodyBehindAppBar: false,
          body: Stack(
            children: [
              Center(
                child: QRView(
                  key: _qrKey,
                  formatsAllowed: const [
                    BarcodeFormat.qrcode
                  ],
                  overlay: QrScannerOverlayShape(
                    borderColor: Colors.white,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 200
                  ),
                  onPermissionSet: (QRViewController controller, bool permission) {
                    DateTime? lastScan;

                    _subscription = _controller!.scannedDataStream.listen((scanData) async {
                      final currentScan = DateTime.now();

                      if (lastScan == null || currentScan.difference(lastScan!) > const Duration(seconds: 2)) {
                        lastScan = currentScan;
                        await vm.readQRCode(scanData.code);
                      }
                    });
                  },
                  onQRViewCreated: (QRViewController controller) {
                    _controller = controller;
                  },
                )
              ),
              Container(
                padding: const EdgeInsets.only(top: 128),
                child: vm.currentOrder == null ? Container() : Align(
                  alignment: Alignment.topCenter,
                  child: Column(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Заказ ${vm.currentOrder!.trackingNumber}',
                        style: const TextStyle(color: Colors.white, fontSize: 20)
                      )
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Мест ${vm.orderPackageScanned!.where((el) => el).length}/${vm.currentOrder!.packages}',
                        style: const TextStyle(color: Colors.white, fontSize: 20)
                      )
                    )
                  ])
                )
              )
            ]
          )
        );
      },
      listener: (context, state) {
        OrderQRScanViewModel vm = context.read<OrderQRScanViewModel>();

        if (state is OrderQRScanFailure) {
          showMessage(state.message);
        } else if (state is OrderQRScanFinished) {
          Navigator.of(context).pop(vm.currentOrder!);
        }
      }
    );
  }
}
