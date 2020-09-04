import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart' as blue;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as blueSerial;
import 'package:iboxpro_flutter/iboxpro_flutter.dart';

class Iboxpro {
  static const String _terminalNamePrefix = 'MPOS';
  Duration _searchTimeout = Duration(seconds: 5);
  String _deviceName;
  Map<dynamic, dynamic> _transaction;
  String _transactionId;

  Iboxpro();

  Future<void> apiLogin({
    @required String login,
    @required String password,
    @required Function onError,
    @required Function onLogin
  }) async {
    await PaymentController.login(
      email: login,
      password: password,
      onLogin: (res) async {
        int errorCode = res['errorCode'];

        if (errorCode == 0) {
          onLogin.call();
        } else {
          onError.call('Ошибка авторизации $errorCode');
        }
      }
    );
  }

  Future<void> connectToDevice({
    @required Function onError,
    @required Function onConnected
  }) async {
    if (!(await blue.FlutterBlue.instance.isOn)) {
      onError.call('Не включен Bluetooth');

      return;
    }

    try {
      _deviceName = await (Platform.isIOS ? _findBTDeviceNameIos() : _findBTDeviceNameAndroid());
    } catch(e) {
      onError.call('Ошибка при установлении связи с терминалом');

      return;
    }

    if (_deviceName == null) {
      onError.call('Не удалось найти терминал');

      return;
    }

    await PaymentController.startSearchBTDevice(
      deviceName: _deviceName,
      onReaderSetBTDevice: onConnected
    );
  }

  Future<void> cancelPayment() async {
    await PaymentController.cancel();
  }

  Future<void> startPayment({
    @required double amount,
    @required String description,
    @required Function onError,
    @required Function onPaymentStart,
    @required Function onPaymentComplete,
  }) async {

    await PaymentController.startPayment(
      amount: amount,
      description: description,
      inputType: InputType.NFC,
      singleStepAuth: true,
      onReaderEvent: (res) async {
        if (res['readerEventType'] == ReaderEventType.Disconnected) {
          onError.call('Прервана связь с терминалом');
        }
      },
      onPaymentStart: (res) async {
        _transactionId = res['id'];
        onPaymentStart.call(_transactionId);
      },
      onPaymentError: (res) async {
        int errorType = res['errorType'];
        String errorMessage = res['errorMessage'];

        onError.call('Ошибка обработки оплаты $errorType; $errorMessage');
      },
      onPaymentComplete: (res) async {
        _transaction = res['transaction'];
        _transaction['deviceName'] = _deviceName;
        onPaymentComplete.call(_transaction, res['requiredSignature']);
      }
    );
  }

  Future<void> adjustPayment({
    @required Uint8List signature,
    @required onError,
    @required onPaymentAdjust
  }) async {
    await PaymentController.adjustPayment(
      trId: _transactionId,
      signature: signature,
      onPaymentAdjust: (res) async {
        int errorCode = res['errorCode'];

        if (errorCode == 0) {
          onPaymentAdjust.call(_transaction);
        } else {
          onError.call('Ошибка сохранения подписи $errorCode');
        }
      }
    );
  }

  Future<String> _findBTDeviceNameIos() async {
    blue.FlutterBlue flutterBlue = blue.FlutterBlue.instance;
    List<blue.ScanResult> results = await flutterBlue.startScan(timeout: _searchTimeout);
    blue.BluetoothDevice device = results.firstWhere(
      (blue.ScanResult result) => result?.device?.name?.contains(_terminalNamePrefix),
      orElse: () => null
    )?.device;

    if (device == null) {
      return null;
    }

    return device.name;
  }

  Future<String> _findBTDeviceNameAndroid() async {
    blueSerial.FlutterBluetoothSerial bluetooth = blueSerial.FlutterBluetoothSerial.instance;
    List<blueSerial.BluetoothDevice> devices = await bluetooth.getBondedDevices();

    if (!devices.any((device) => device.name.contains(_terminalNamePrefix))) {
      List<blueSerial.BluetoothDiscoveryResult> results = [];
      StreamSubscription<blueSerial.BluetoothDiscoveryResult> subscription= bluetooth.startDiscovery().
        listen((r) => results.add(r));
      await Future.delayed(_searchTimeout);
      subscription.cancel();

      devices.addAll(
        results
          .where((blueSerial.BluetoothDiscoveryResult result) => result.device != null)
          .map((result) => result.device)
      );
    }

    blueSerial.BluetoothDevice device = devices
      .where((device) => device.name != null)
      .firstWhere((device) => device.name.contains(_terminalNamePrefix), orElse: () => null);

    if (device == null) {
      return null;
    }

    if (!device.isBonded) await bluetooth.bondDeviceAtAddress(device.address);

    return device.name;
  }
}
