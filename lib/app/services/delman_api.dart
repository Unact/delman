import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:u_app_utils/u_app_utils.dart';

import '/app/entities/entities.dart';

extension DelmanApi on RenewApi {
  Future<ApiUserData> getUserData() async {
    return ApiUserData.fromJson(await get('v1/delman/user_info'));
  }

  Future<ApiData> getData() async {
    return ApiData.fromJson(await get('v1/delman'));
  }

  Future<ApiFindOrderData?> findOrderData({
    required String trackingNumber
  }) async {
    final orderData = await get('v1/delman/find_order', queryParameters: { 'trackingNumber': trackingNumber });

    return orderData != null ? ApiFindOrderData.fromJson(orderData) : null;
  }

  Future<void> arriveAtDeliveryPoint({
    required int deliveryPointId,
    required DateTime factArrival,
    required Location location,
  }) async {
    return await post(
      'v1/delman/arrive',
      dataGenerator: () => {
        'deliveryPointId': deliveryPointId,
        'factArrival': factArrival.toIso8601String(),
        'location': location
      }
    );
  }

  Future<void> cancelOrder({
    required int deliveryPointOrderId,
    required Location location
  }) async {
    return await post(
      'v1/delman/cancel_order',
      dataGenerator: () => {
        'deliveryPointOrderId': deliveryPointOrderId,
        'location': location
      }
    );
  }

  Future<void> confirmOrderFacts({
    required int deliveryPointOrderId,
    required List<Map<String, dynamic>> orderLines,
  }) async {
    return await post(
      'v1/delman/confirm_order_facts',
      dataGenerator: () => {
        'deliveryPointOrderId': deliveryPointOrderId,
        'orderLines': orderLines
      }
    );
  }

  Future<void> confirmOrder({
    required int deliveryPointOrderId,
    required Location location,
  }) async {
    return await post(
      'v1/delman/confirm_order',
      dataGenerator: () => {
        'deliveryPointOrderId': deliveryPointOrderId,
        'location': location
      }
    );
  }

  Future<ApiPaymentCredentials> getPaymentCredentials() async {
    return ApiPaymentCredentials.fromJson(await get('v1/delman/credentials'));
  }

  Future<void> acceptPayment({
    required int deliveryPointOrderId,
    required double summ,
    required Location location,
    Map<dynamic, dynamic>? transaction,
  }) async {
    return post(
      'v1/delman/accept_payment',
      dataGenerator: () => {
        'deliveryPointOrderId': deliveryPointOrderId,
        'summ': summ,
        'paymentTransaction': transaction,
        'location': location
      }
    );
  }

  Future<void> saveLogs({
    required List<Log> logs
  }) async {
    String deviceModel;
    String osVersion;

    Directory dir = await getTemporaryDirectory();
    File file = File('${dir.path}/${DateTime.now().toIso8601String()}-log.json');

    await file.writeAsString(jsonEncode(logs.map((e) => e.toJson()).toList()));

    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await DeviceInfoPlugin().iosInfo;
      osVersion = iosDeviceInfo.systemVersion;
      deviceModel = iosDeviceInfo.utsname.machine;
    } else {
      AndroidDeviceInfo androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
      osVersion = androidDeviceInfo.version.release;
      deviceModel = '${androidDeviceInfo.brand} - ${androidDeviceInfo.model}';
    }

    return post('v1/delman/save_log',
      dataGenerator: () => FormData.fromMap({
        'deviceModel': deviceModel,
        'osVersion': osVersion,
        'file': MultipartFile.fromBytes(file.readAsBytesSync(), filename: file.path.split('/').last)
      })
    );
  }

  Future<void> takeNewOrder({
    required int orderId
  }) async {
    return await post(
      'v1/delman/take_new_order',
      dataGenerator: () => {
        'orderId': orderId
      }
    );
  }

  Future<void> acceptOrder({
    required int orderId
  }) async {
    return await post(
      'v1/delman/accept_order',
      dataGenerator: () => {
        'orderId': orderId
      }
    );
  }

  Future<void> transferOrder({
    required int orderId,
    required int orderStorageId
  }) async {
    return await post(
      'v1/delman/transfer_order',
      dataGenerator: () => {
        'orderId': orderId,
        'storageId': orderStorageId
      }
    );
  }

  Future<void> addOrderInfo({
    required int orderId,
    required String comment
  }) async {
    return post(
      'v1/delman/add_order_system_info',
      dataGenerator: () => {
        'orderId': orderId,
        'comment': comment
      }
    );
  }

  Future<void> closeDelivery() async {
    return await post('v1/delman/close_delivery');
  }
}
