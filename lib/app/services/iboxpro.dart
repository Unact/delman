import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as blue_serial;
import 'package:iboxpro_flutter/iboxpro_flutter.dart';

class Iboxpro {
  static const String _terminalNamePrefix = 'MPOS';
  final Duration _searchTimeout = const Duration(seconds: 5);
  String? _deviceName;
  Map<dynamic, dynamic>? _transaction;
  String? _transactionId;

  Iboxpro();

  Future<void> apiLogin({
    required String login,
    required String password,
    required Function onError,
    required Function onLogin
  }) async {
    await PaymentController.login(
      email: login,
      password: password,
      onLogin: (Result res) async {
        int errorCode = res.errorCode;

        if (errorCode == 0) {
          onLogin.call();
        } else {
          onError.call('Ошибка авторизации $errorCode');
        }
      }
    );
  }

  Future<void> connectToDevice({
    required Function(String) onError,
    required Function() onConnected
  }) async {
    if (await blue.FlutterBluePlus.adapterState.first != blue.BluetoothAdapterState.on) {
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
      deviceName: _deviceName!,
      onReaderSetBTDevice: onConnected
    );
  }

  Future<void> cancelPayment() async {
    await PaymentController.cancel();
  }

  Future<void> startPayment({
    required double amount,
    required String description,
    required Function onError,
    required Function onPaymentStart,
    required Function onPaymentComplete,
  }) async {

    await PaymentController.startPayment(
      amount: amount,
      description: description,
      inputType: InputType.NFC,
      singleStepAuth: true,
      onReaderEvent: (ReaderEvent res) async {
        if (res.type == ReaderEventType.Disconnected) {
          onError.call('Прервана связь с терминалом');
        }
      },
      onPaymentStart: (String id) async {
        _transactionId = id;
        onPaymentStart.call(_transactionId);
      },
      onPaymentError: (PaymentError res) async {
        int errorType = res.type;
        String errorMessage = res.message;

        onError.call('Ошибка обработки оплаты $errorType; $errorMessage');
      },
      onPaymentComplete: (Transaction transaction, bool requiredSignature) async {
        _transaction = transaction.toMap();
        _transaction!['deviceName'] = _deviceName;
        onPaymentComplete.call(_transaction, requiredSignature);
      }
    );
  }

  Future<void> adjustPayment({
    required Uint8List signature,
    required onError,
    required onPaymentAdjust
  }) async {
    await PaymentController.adjustPayment(
      id: _transactionId!,
      signature: signature,
      onPaymentAdjust: (Result res) async {
        int errorCode = res.errorCode;

        if (errorCode == 0) {
          onPaymentAdjust.call(_transaction);
        } else {
          onError.call('Ошибка сохранения подписи $errorCode');
        }
      }
    );
  }

  Future<String?> _findBTDeviceNameIos() async {
    List<blue.ScanResult> results = await blue.FlutterBluePlus.startScan(timeout: _searchTimeout);
    blue.BluetoothDevice? device = results.firstWhereOrNull(
      (blue.ScanResult result) => result.device.localName.contains(_terminalNamePrefix)
    )?.device;

    if (device == null) {
      return null;
    }

    return device.localName;
  }

  Future<String?> _findBTDeviceNameAndroid() async {
    blue_serial.FlutterBluetoothSerial bluetooth = blue_serial.FlutterBluetoothSerial.instance;

    List<blue_serial.BluetoothDiscoveryResult> results = [];
    StreamSubscription<blue_serial.BluetoothDiscoveryResult> subscription = bluetooth.startDiscovery().
      listen((r) => results.add(r));
    await Future.delayed(_searchTimeout);
    await subscription.cancel();

    List<blue_serial.BluetoothDevice> bondedDevices = await bluetooth.getBondedDevices();
    List<blue_serial.BluetoothDevice> localDevices = results.map((result) => result.device).toList();
    bool search(blue_serial.BluetoothDevice device) => (device.name ?? '').contains(_terminalNamePrefix);

    blue_serial.BluetoothDevice? bondedDevice = bondedDevices.firstWhereOrNull(search);
    blue_serial.BluetoothDevice? localDevice = localDevices.firstWhereOrNull(search);
    blue_serial.BluetoothDevice? device = bondedDevice == localDevice ? bondedDevice : localDevice;

    if (device == null) return null;
    if (!device.isBonded) await bluetooth.bondDeviceAtAddress(device.address);

    return device.name;
  }
}
