import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';

import '/app/constants/strings.dart';
import '/app/entities/entities.dart';

class Api {
  static const String authSchema = 'Renew';
  static const _kAccessTokenKey = 'accessToken';
  static const _kRefreshTokenKey = 'refreshToken';
  static const _kUrlKey = 'url';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  late Dio _dio;
  final String _version;
  String _refreshToken;
  String _url;
  String _accessToken;

  Api._(
    this._url,
    this._accessToken,
    this._refreshToken,
    this._version
  ) {
    _dio = _createDio(_url, _version, _accessToken);
  }

  Future<void> _setApiData(String url, String accessToken, String refreshToken) async {
    await _storage.write(key: _kUrlKey, value: url);
    await _storage.write(key: _kAccessTokenKey, value: accessToken);
    await _storage.write(key: _kRefreshTokenKey, value: refreshToken);

    _url = url;
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _dio = _createDio(_url, _version, _accessToken);
  }

  static Future<Api> init() async {
    return Api._(
      await _storage.read(key: _kUrlKey) ?? '',
      await _storage.read(key: _kAccessTokenKey) ?? '',
      await _storage.read(key: _kRefreshTokenKey) ?? '',
      (await PackageInfo.fromPlatform()).version
    );
  }

  bool get isLoggedIn => _accessToken != '';

  Future<void> login({
    required String url,
    required String login,
    required String password
  }) async {
    await _setApiData(url, '', '');
    Map<String, dynamic> result = await _sendRawRequest(() => _dio.post(
      'v2/authenticate',
      options: Options(headers: { 'Authorization': '$authSchema login=$login,password=$password' })
    ));

    await _setApiData(url, result['access_token'], result['refresh_token']);
  }

  Future<void> refresh() async {
    await _setApiData(_url, _refreshToken, '');
    Map<String, dynamic> result = await _sendRawRequest(() => _dio.post('v2/refresh'));

    await _setApiData(_url, result['access_token'], result['refresh_token']);
  }

  Future<void> logout() async {
    await _setApiData('', '', '');
  }

  Future<void> resetPassword({
    required String url,
    required String login
  }) async {
    await _sendRawRequest(() async {
      _dio = _createDio(_url, _version, null);

      return await _dio.post(
        'v2/reset_password',
        options: Options(headers: { 'Authorization': '$authSchema login=$login' })
      );
    });
  }

  Future<ApiUserData> getUserData() async {
    return ApiUserData.fromJson(await _sendRequest(() => _dio.get('v1/delman/user_info')));
  }

  Future<ApiData> getData() async {
    return ApiData.fromJson(await _sendRequest(() => _dio.get('v1/delman')));
  }

  Future<ApiFindOrderData?> findOrderData({
    required String trackingNumber
  }) async {
    final orderData = await _sendRequest(() => _dio.get(
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
    return await _sendRequest(() => _dio.post(
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
    return await _sendRequest(() => _dio.post(
      'v1/delman/cancel_order',
      data: {
        'deliveryPointOrderId': deliveryPointOrderId,
        'location': location
      }
    ));
  }

  Future<void> confirmOrderFacts({
    required int deliveryPointOrderId,
    required List<Map<String, dynamic>> orderLines,
  }) async {
    return await _sendRequest(() => _dio.post(
      'v1/delman/confirm_order_facts',
      data: {
        'deliveryPointOrderId': deliveryPointOrderId,
        'orderLines': orderLines
      }
    ));
  }

  Future<void> confirmOrder({
    required int deliveryPointOrderId,
    required Location location,
  }) async {
    return await _sendRequest(() => _dio.post(
      'v1/delman/confirm_order',
      data: {
        'deliveryPointOrderId': deliveryPointOrderId,
        'location': location
      }
    ));
  }

  Future<ApiPaymentCredentials> getPaymentCredentials() async {
    return ApiPaymentCredentials.fromJson(await _sendRequest(() => _dio.get('v1/delman/credentials')));
  }

  Future<void> acceptPayment({
    required int deliveryPointOrderId,
    required double summ,
    required Location location,
    Map<dynamic, dynamic>? transaction,
  }) async {
    return await _sendRequest(() => _dio.post(
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

    return await _sendRequest(() => _dio.post('v1/delman/save_log',
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
    return await _sendRequest(() => _dio.post(
      'v1/delman/take_new_order',
      data: {
        'orderId': orderId
      }
    ));
  }

  Future<void> acceptOrder({
    required int orderId
  }) async {
    return await _sendRequest(() => _dio.post(
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
    return await _sendRequest(() => _dio.post(
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
    return await _sendRequest(() => _dio.post(
      'v1/delman/add_order_system_info',
      data: {
        'orderId': orderId,
        'comment': comment
      }
    ));
  }

  Future<void> closeDelivery() async {
    return await _sendRequest(() => _dio.post('v1/delman/close_delivery'));
  }

  Future<dynamic> _sendRequest(Future<Response> Function() request) async {
    try {
      return await _sendRawRequest(request);
    } on AuthException {
      await refresh();
      return await _sendRawRequest(request);
    }
  }

  Future<dynamic> _sendRawRequest(Future<Response> Function() rawRequest) async {
    try {
      return (await rawRequest.call()).data;
    } on DioException catch(e) {
      _onDioException(e);
    }
  }

  Dio _createDio(String url, String version, String? token) {
    String appName = Strings.appName;
    Map<String, dynamic> headers = {
      'Accept': 'application/json',
      appName: version,
      'Authorization': '$authSchema token=$token',
      HttpHeaders.userAgentHeader: '$appName/$version ${FkUserAgent.userAgent}',
    };

    return Dio(BaseOptions(
      baseUrl: url,
      connectTimeout: const Duration(seconds: 100000),
      receiveTimeout: const Duration(seconds: 100000),
      headers: headers,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));
  }

  static void _onDioException(DioException e) {
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
      if (
        e.error is SocketException ||
        e.error is HandshakeException ||
        e.error is HttpException ||
        e.type == DioExceptionType.connectionTimeout
      ) {
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
