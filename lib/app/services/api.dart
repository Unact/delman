import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

import '/app/constants/strings.dart';
import '/app/entities/entities.dart';
import '/app/data/database.dart';

class Api {
  static const String authSchema = 'Renew';

  final AppStorage storage;

  Api({
    required this.storage
  });

  Future<void> login({
    required String url,
    required String login,
    required String password
  }) async {
    Map<String, dynamic> result = await _sendRawRequest(() async {
      Dio dio = await _createDio(url, null);

      return await dio.post(
        'v2/authenticate',
        options: Options(headers: { 'Authorization': '$authSchema login=$login,password=$password' })
      );
    });

    ApiCredential apiCredential = (await _getApiCredentials()).copyWith(
      accessToken: result['access_token'],
      refreshToken: result['refresh_token'],
      url: url
    );

    await storage.apiCredentialsDao.updateApiCredential(apiCredential);
  }

  Future<void> refresh() async {
    ApiCredential apiCredential = await _getApiCredentials();
    Map<String, dynamic> result = await _sendRawRequest(() async {
      Dio dio = await _createDio(apiCredential.url, apiCredential.refreshToken);

      return await dio.post('v2/refresh');
    });

    ApiCredential newApiCredential = apiCredential.copyWith(
      accessToken: result['access_token'],
      refreshToken: result['refresh_token']
    );

    await storage.apiCredentialsDao.updateApiCredential(newApiCredential);
  }

  Future<void> logout() async {
    await storage.apiCredentialsDao.deleteApiCredential();
  }

  Future<void> resetPassword({
    required String url,
    required String login
  }) async {
    await _sendRawRequest(() async {
      Dio dio = await _createDio(url, null);

      return await dio.post(
        'v2/reset_password',
        options: Options(headers: { 'Authorization': '$authSchema login=$login' })
      );
    });
  }

  Future<ApiUserData> getUserData() async {
    return ApiUserData.fromJson(await _sendRequest((dio) => dio.get('v1/delman/user_info')));
  }

  Future<ApiData> getData() async {
    return ApiData.fromJson(await _sendRequest((dio) => dio.get('v1/delman')));
  }

  Future<ApiFindOrderData?> findOrderData({
    required String trackingNumber
  }) async {
    final orderData = await _sendRequest((dio) => dio.get(
      'v1/delman/find_order',
      queryParameters: { 'trackingNumber': trackingNumber }
    ));

    return orderData != null ? ApiFindOrderData.fromJson(orderData) : null;
  }

  Future<void> arriveAtDeliveryPoint({
    required int deliveryPointId,
    required DateTime factArrival,
    required Location location,
  }) async {
    return await _sendRequest((dio) => dio.post(
      'v1/delman/arrive',
      data: {
        'deliveryPointId': deliveryPointId,
        'factArrival': factArrival.toIso8601String(),
        'location': location
      }
    ));
  }

  Future<void> cancelOrder({
    required int deliveryPointOrderId,
    required Location location
  }) async {
    return await _sendRequest((dio) => dio.post(
      'v1/delman/cancel_order',
      data: {
        'deliveryPointOrderId': deliveryPointOrderId,
        'location': location
      }
    ));
  }

  Future<void> confirmOrder({
    required int deliveryPointOrderId,
    required List<Map<String, dynamic>> orderLines,
    required Location location,
  }) async {
    return await _sendRequest((dio) => dio.post(
      'v1/delman/confirm_order',
      data: {
        'deliveryPointOrderId': deliveryPointOrderId,
        'orderLines': orderLines,
        'location': location
      }
    ));
  }

  Future<ApiPaymentCredentials> getPaymentCredentials() async {
    return ApiPaymentCredentials.fromJson(await _sendRequest((dio) => dio.get('v1/delman/credentials')));
  }

  Future<void> acceptPayment({
    required int deliveryPointOrderId,
    required double summ,
    required Location location,
    Map<dynamic, dynamic>? transaction,
  }) async {
    return await _sendRequest((dio) => dio.post(
      'v1/delman/accept_payment',
      data: {
        'deliveryPointOrderId': deliveryPointOrderId,
        'summ': summ,
        'paymentTransaction': transaction,
        'location': location
      }
    ));
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
      osVersion = iosDeviceInfo.systemVersion ?? '';
      deviceModel = iosDeviceInfo.utsname.machine ?? '';
    } else {
      AndroidDeviceInfo androidDeviceInfo = await DeviceInfoPlugin().androidInfo;
      osVersion = androidDeviceInfo.version.release ?? '';
      deviceModel = (androidDeviceInfo.brand ?? '') + ' - ' + (androidDeviceInfo.model ?? '');
    }

    return await _sendRequest((dio) => dio.post('v1/delman/save_log',
      data: FormData.fromMap({
        'deviceModel': deviceModel,
        'osVersion': osVersion,
        'file': MultipartFile.fromBytes(file.readAsBytesSync(), filename: file.path.split('/').last)
      })
    ));
  }

  Future<void> takeNewOrder({
    required int orderId
  }) async {
    return await _sendRequest((rawApi) => rawApi.post(
      'v1/delman/take_new_order',
      data: {
        'orderId': orderId
      }
    ));
  }

  Future<void> acceptOrder({
    required int orderId
  }) async {
    return await _sendRequest((rawApi) => rawApi.post(
      'v1/delman/accept_order',
      data: {
        'orderId': orderId
      }
    ));
  }

  Future<void> transferOrder({
    required int orderId,
    required int orderStorageId
  }) async {
    return await _sendRequest((dio) => dio.post(
      'v1/delman/transfer_order',
      data: {
        'orderId': orderId,
        'storageId': orderStorageId
      }
    ));
  }

  Future<void> addOrderInfo({
    required int orderId,
    required String comment
  }) async {
    return await _sendRequest((dio) => dio.post(
      'v1/delman/add_order_system_info',
      data: {
        'orderId': orderId,
        'comment': comment
      }
    ));
  }

  Future<void> closeDelivery() async {
    return await _sendRequest((dio) => dio.post('v1/delman/close_delivery'));
  }

  Future<dynamic> _sendRequest(Future<dynamic> Function(Dio) request) async {
    ApiCredential apiCredential = await _getApiCredentials();

    try {
      return await _sendRawRequest(() async {
        Dio dio = await _createDio(apiCredential.url, apiCredential.accessToken);

        return await request.call(dio);
      });
    } on AuthException {
      await refresh();
      ApiCredential newApiCredential = await _getApiCredentials();
      Dio newDio = await _createDio(newApiCredential.url, newApiCredential.accessToken);

      return await _sendRawRequest(() async {
        return await request.call(newDio);
      });
    }
  }

  Future<dynamic> _sendRawRequest(Future<Response> Function() rawRequest) async {
    try {
      return (await rawRequest.call()).data;
    } on DioError catch(e) {
      _onDioError(e);
    }
  }

  Future<ApiCredential> _getApiCredentials() async {
    return await storage.apiCredentialsDao.getApiCredential();
  }

  Future<Dio> _createDio(String url, String? token) async {
    String version = (await PackageInfo.fromPlatform()).version;
    String appName = Strings.appName;
    Map<String, dynamic> headers = {
      'Accept': 'application/json',
      appName: version,
      'Authorization': '$authSchema token=$token',
      HttpHeaders.userAgentHeader: '$appName/$version ${FkUserAgent.userAgent}',
    };

    return Dio(BaseOptions(
      baseUrl: url,
      connectTimeout: 100000,
      receiveTimeout: 100000,
      headers: headers,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));
  }

  static void _onDioError(DioError e) {
    if (e.response != null) {
      final int statusCode = e.response!.statusCode!;
      final dynamic body = e.response!.data;

      if (statusCode < 200) {
        throw ApiException('Ошибка при получении данных', statusCode);
      }

      if (statusCode >= 500) {
        throw ServerException(statusCode);
      }

      if (statusCode == 401) {
        throw AuthException(body['error']);
      }

      if (statusCode == 410) {
        throw VersionException(body['error']);
      }

      if (statusCode >= 400) {
        throw ApiException(body['error'], statusCode);
      }
    } else {
      if (e.error is SocketException || e.error is HandshakeException || e.type == DioErrorType.connectTimeout) {
        throw ApiConnException();
      }

      throw e;
    }
  }
}

class ApiException implements Exception {
  String errorMsg;
  int statusCode;

  ApiException(this.errorMsg, this.statusCode);
}

class AuthException extends ApiException {
  AuthException(errorMsg) : super(errorMsg, 401);
}

class ServerException extends ApiException {
  ServerException(statusCode) : super('Нет связи с сервером', statusCode);
}

class ApiConnException extends ApiException {
  ApiConnException() : super('Нет связи', 503);
}

class VersionException extends ApiException {
  VersionException(errorMsg) : super(errorMsg, 410);
}
