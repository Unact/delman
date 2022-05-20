import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:rxdart/rxdart.dart';

import '/app/data/database.dart';
import '/app/constants/strings.dart';
import '/app/entities/entities.dart';
import '/app/pages/shared/page_view_model.dart';
import '/app/services/api.dart';

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

  Duration kThrottle = const Duration(seconds: 2);

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
                    _subscription = _controller!.scannedDataStream.throttleTime(kThrottle).listen((scanData) async {
                      if (vm.state.status == OrderQRScanStateStatus.scanReadStarted) return;

                      await vm.readQRCode(scanData.code);
                    });
                  },
                  onQRViewCreated: (QRViewController controller) {
                    _controller = controller;
                  },
                )
              ),
              Container(
                padding: const EdgeInsets.only(top: 128),
                child: Align(alignment: Alignment.topCenter, child: _buildOrderInfo(context))
              )
            ]
          )
        );
      },
      listener: (context, state) async {
        switch (state.status) {
          case OrderQRScanStateStatus.failure:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            await _controller!.resumeCamera();
            break;
          case OrderQRScanStateStatus.finished:
            Navigator.of(context).pop(state.order!);
            break;
          default:
        }
      }
    );
  }

  Widget _buildOrderInfo(BuildContext context) {
    OrderQRScanViewModel vm = context.read<OrderQRScanViewModel>();

    if (vm.state.status == OrderQRScanStateStatus.scanReadStarted) {
      return const CircularProgressIndicator(color: Colors.white);
    }

    if (vm.state.order == null) return Container();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Заказ ${vm.state.order!.trackingNumber}',
            style: const TextStyle(color: Colors.white, fontSize: 20)
          )
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'Мест ${vm.state.orderPackageScanned.where((el) => el).length}/${vm.state.order!.packages}',
            style: const TextStyle(color: Colors.white, fontSize: 20)
          )
        )
      ]
    );
  }
}
