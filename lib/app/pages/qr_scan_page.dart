import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  _QRScanPageState createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: <Widget>[
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.flash_on),
            onPressed: () async {
              _controller!.toggleFlash();
            }
          ),
          IconButton(
            color: Colors.white,
            icon: Icon(Icons.switch_camera),
            onPressed: () async {
              _controller!.flipCamera();
            }
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: QRView(
          key: _qrKey,
          overlay: QrScannerOverlayShape(
            borderColor: Colors.white,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: 200
          ),
          onPermissionSet: (QRViewController controller, bool permission) {
            _subscription = _controller!.scannedDataStream.listen((scanData) {
              _subscription!.cancel();
              Navigator.pop(context, scanData.code);
            });
          },
          onQRViewCreated: (QRViewController controller) {
            _controller = controller;
          },
        )
      )
    );
  }
}
