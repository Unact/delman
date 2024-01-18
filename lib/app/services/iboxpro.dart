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

  final Function(String) onError;
  final Function onStart;
  final Function onComplete;
  final Function onConnected;
  final Function onLogin;
  final Function? onCheck;
  final Function? onAdjust;
  final Function? onReverseAdjust;
  final Function? onNeedExternalComplete;

  late final StreamSubscription<PaymentLoginEvent> _onLoginSubscription;
  late final StreamSubscription<PaymentReaderSetDeviceEvent> _onReaderSetDeviceSubscription;
  late final StreamSubscription<PaymentErrorEvent> _onPaymentErrorSubscription;
  late final StreamSubscription<PaymentStartEvent> _onPaymentStartSubscription;
  late final StreamSubscription<PaymentReaderEvent> _onReaderSubscription;
  late final StreamSubscription<PaymentCompleteEvent> _onPaymentCompleteSubscription;
  late final StreamSubscription<PaymentRejectReverseEvent> _onRejectReverseSubscription;
  late final StreamSubscription<PaymentInfoEvent> _onInfoSubscription;
  late final StreamSubscription<PaymentAdjustEvent> _onPaymentAdjustSubscription;
  late final StreamSubscription<PaymentAdjustReverseEvent> _onPaymentAdjustReverseSubscription;

  Iboxpro({
    required this.onError,
    required this.onStart,
    required this.onComplete,
    required this.onConnected,
    required this.onLogin,
    this.onCheck,
    this.onAdjust,
    this.onReverseAdjust,
    this.onNeedExternalComplete
  }) {
    _onPaymentErrorSubscription = PaymentController.onPaymentError.listen(_onPaymentError);
    _onPaymentStartSubscription = PaymentController.onPaymentStart.listen(_onPaymentStart);
    _onReaderSubscription = PaymentController.onReader.listen(_onReader);
    _onPaymentCompleteSubscription = PaymentController.onPaymentComplete.listen(_onPaymentComplete);
    _onLoginSubscription = PaymentController.onLogin.listen(_onLogin);
    _onReaderSetDeviceSubscription = PaymentController.onReaderSetDevice.listen(_onReaderSetDevice);
    _onPaymentAdjustSubscription = PaymentController.onPaymentAdjust.listen(_onPaymentAdjust);
    _onRejectReverseSubscription = PaymentController.onRejectReverse.listen(_onRejectReverse);
    _onPaymentAdjustReverseSubscription = PaymentController.onPaymentAdjustReverse.listen(_onPaymentAdjustReverse);
    _onInfoSubscription = PaymentController.onInfo.listen(_onInfo);
  }

  void dispose() {
    _onPaymentErrorSubscription.cancel();
    _onPaymentStartSubscription.cancel();
    _onReaderSubscription.cancel();
    _onPaymentCompleteSubscription.cancel();
    _onLoginSubscription.cancel();
    _onReaderSetDeviceSubscription.cancel();
    _onPaymentAdjustSubscription.cancel();
    _onRejectReverseSubscription.cancel();
    _onPaymentAdjustReverseSubscription.cancel();
    _onInfoSubscription.cancel();
  }

  Future<void> apiLogin({required String login, required String password}) async {
    await PaymentController.login(email: login, password: password);
  }

  Future<void> checkPayment() async {
    await PaymentController.info(id: _transactionId!);
  }

  Future<void> connectToDevice() async {
    if (await blue.FlutterBluePlus.adapterState.first != blue.BluetoothAdapterState.on) {
      onError.call('Не включен Bluetooth');

      return;
    }

    try {
      String? deviceName = await (Platform.isIOS ? _findBTDeviceNameIos() : _findBTDeviceNameAndroid());

      if (deviceName == null) {
        onError.call('Не удалось найти терминал');

        return;
      }

      await PaymentController.startSearchBTDevice(deviceName: deviceName);
    } catch(e) {
      onError.call('Ошибка при установлении связи с терминалом');

      return;
    }
  }

  Future<void> cancelPayment() async {
    await PaymentController.cancel();
  }

  Future<void> startPayment({required double amount, required String description, required bool isLink}) async {
    await PaymentController.startPayment(
      amount: amount,
      description: description,
      inputType: isLink ? InputType.link : InputType.nfc
    );
  }

  Future<void> adjustPayment({required Uint8List signature}) async {
    await PaymentController.adjustPayment(id: _transactionId!, signature: signature);
  }

  Future<void> startReversePayment({required String id, required double amount, required String description}) async {
    _transactionId = id;

    await PaymentController.startReversePayment(
      id: _transactionId!,
      amount: amount,
      description: description
    );
  }

  Future<void> adjustReversePayment({required Uint8List signature}) async {
    await PaymentController.adjustReversePayment(
      id: _transactionId!,
      signature: signature
    );
  }

  void _onPaymentError(PaymentErrorEvent event) {
    PaymentError error = event.error;

    onError.call('Ошибка обработки ${error.type}; ${error.message}');
  }

  void _onPaymentStart(PaymentStartEvent event) {
    _transactionId = event.id;

    onStart.call(event.id);
  }

  void _onReader(PaymentReaderEvent event) {
    ReaderEvent readerEvent = event.readerEvent;

    if (readerEvent.type == ReaderEventType.disconnected) onError.call('Прервана связь с терминалом');
  }

  void _onPaymentComplete(PaymentCompleteEvent event) {
    _transaction = event.transaction.toMap();
    _transaction!['deviceName'] = _deviceName;

    if (event.transaction.externalPaymentData.isNotEmpty) {
      onNeedExternalComplete?.call(event.transaction.externalPaymentData[0].value);
    } else {
      onComplete.call(event.transaction.toMap(), event.requiredSignature);
    }
  }

  void _onLogin(PaymentLoginEvent event) {
    int errorCode = event.result.errorCode;

    if (errorCode == 0) {
      onLogin.call();
    } else {
      onError.call('Ошибка авторизации $errorCode');
    }
  }

  void _onReaderSetDevice(PaymentReaderSetDeviceEvent event) {
    _deviceName = event.deviceName;

    onConnected.call(event.deviceName);
  }

  void _onPaymentAdjust(PaymentAdjustEvent event) {
    int errorCode = event.result.errorCode;

    if (errorCode == 0) {
      onAdjust?.call();
    } else {
      onError.call('Ошибка сохранения подписи $errorCode');
    }
  }

  void _onRejectReverse(PaymentRejectReverseEvent event) {
    onError.call('Данную оплату нельзя отменить');
  }

  void _onPaymentAdjustReverse(PaymentAdjustReverseEvent event) {
    int errorCode = event.result.errorCode;

    if (errorCode == 0) {
      onReverseAdjust?.call();
    } else {
      onError.call('Ошибка сохранения подписи для отмены $errorCode');
    }
  }

  void _onInfo(PaymentInfoEvent event) {
    if (event.transaction != null) {
      onCheck?.call(event.transaction!.toMap(), !event.transaction!.isNotFinished);
    } else {
      onError.call('Ошибка получения данных об оплате');
    }
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
