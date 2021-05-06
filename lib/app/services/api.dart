import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:f_logs/f_logs.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/repositories/repositories.dart';

class Api {
  final ApiDataRepository repo;
  final String version;
  static const String authSchema = 'Renew';

  Api._({@required this.repo, @required this.version}) {
    _instance = this;
  }

  static Api _instance;
  static Api get instance => _instance;

  static Api init({@required ApiDataRepository repo, @required String version}) {
    if (_instance != null)
      return _instance;

    return Api._(repo: repo, version: version);
  }

  Future<void> resetPassword(String url, String login) async {
    await logout();
    await _rawRequest(
      ApiData(login: login, url: url),
      'POST',
      'v1/reset_password',
      headers: {
        'Authorization': '$authSchema login=$login'
      }
    );
  }

  Future<ApiData> login(String url, String login, String password) async {
    ApiData loginData = ApiData(login: login, password: password, url: url);

    ApiData authData = await _authenticate(loginData);
    await repo.setApiData(authData);

    return authData;
  }

  Future<void> logout() async {
    await repo.resetApiData();
  }

  Future<ApiData> relogin() async {
    ApiData currentAuthData = repo.getApiData();
    return await login(currentAuthData.url, currentAuthData.login, currentAuthData.password);
  }

  Future<User> getUserData() async {
    dynamic userData = await _get('v1/delman/user_info');

    return User(
      id: userData['id'],
      username: userData['username'],
      email: userData['email'],
      courierName: userData['courierName'],
      courierStorageId: userData['courierStorageId'],
      version: userData['app']['version']
    );
  }

  Future<Map<String, dynamic>> getData() async {
    dynamic data = await _get('v1/delman');
    List<DeliveryPoint> deliveryPoints = data['deliveryPoints']
      .map<DeliveryPoint>((e) => DeliveryPoint.fromJson(e)).toList();
    List<Delivery> deliveries = data['deliveries']
      .map<Delivery>((e) => Delivery.fromJson(e)).toList();
    List<OrderLine> orderLines = data['orderLines']
      .map<OrderLine>((e) => OrderLine.fromJson(e)).toList();
    List<Order> orders = data['orders']
      .map<Order>((e) => Order.fromJson(e)).toList();
    List<OrderStorage> orderStorages = data['orderStorages']
      .map<OrderStorage>((e) => OrderStorage.fromJson(e)).toList();
    List<Payment> payments = data['payments']
      .map<Payment>((e) => Payment.fromJson(e)).toList();

    return {
      'deliveryPoints': deliveryPoints,
      'deliveries': deliveries,
      'orderLines': orderLines,
      'orders': orders,
      'orderStorages': orderStorages,
      'payments': payments
    };
  }

  Future<void> arriveAtDeliveryPoint(DeliveryPoint deliveryPoint, Location location) async {
    await _post('v1/delman/arrive', data: {
      'deliveryPointId': deliveryPoint.id,
      'factArrival': deliveryPoint.factArrival.toIso8601String(),
      'location': location
    });
  }

  Future<void> cancelOrder(Order order, Location location) async {
    await _post('v1/delman/cancel_order', data: {
      'deliveryPointOrderId': order.id,
      'location': location
    });
  }

  Future<void> confirmOrder(Order order, List<OrderLine> orderLines, Location location) async {
    await _post('v1/delman/confirm_order', data: {
      'deliveryPointOrderId': order.id,
      'orderLines': orderLines.map((e) => {'id': e.id, 'factAmount': e.factAmount}).toList(),
      'location': location
    });
  }

  Future<Map<String, dynamic>> getPaymentCredentials() async {
    return await _get('v1/delman/credentials');
  }

  Future<void> acceptPayment(Payment payment, Map<dynamic, dynamic> transaction, Location location) async {
    await _post('v1/delman/accept_payment', data: {
      'deliveryPointOrderId': payment.deliveryPointOrderId,
      'summ': payment.summ,
      'paymentTransaction': transaction,
      'location': location
    });
  }

  Future<void> saveLogs(List<Log> logs, String deviceModel, String osVersion) async {
    Directory dir = await getTemporaryDirectory();
    DateTime date = DateTime.now();
    File file = File('${dir.path}/${date.toIso8601String()}-log.json');

    await file.writeAsString(jsonEncode(logs.map((e) => e.toJson()).toList()));

    await _post('v1/delman/save_log',
      data: <String, dynamic>{
        'deviceModel': deviceModel,
        'osVersion': osVersion
      },
      file: file
    );
  }

  Future<void> acceptOrder(Order order) async {
    await _post('v1/delman/accept_order', data: {
      'deliveryPointOrderId': order.id
    });
  }

  Future<void> transferOrder(Order order, OrderStorage orderStorage) async {
    await _post('v1/delman/transfer_order', data: {
      'deliveryPointOrderId': order.id,
      'storageId': orderStorage.id
    });
  }

  Future<dynamic> _get(
    String method,
    {
      Map<String, String> headers,
      Map<String, dynamic> queryParameters,
    }
  ) async {
    return await _request(
      repo.getApiData(),
      'GET',
      method,
      headers: headers,
      queryParameters: queryParameters
    );
  }

  Future<dynamic> _post(
    String method,
    {
      Map<String, String> headers,
      Map<String, dynamic> queryParameters,
      dynamic data,
      File file,
      String fileKey = 'file'
    }
  ) async {
    return await _request(
      repo.getApiData(),
      'POST',
      method,
      headers: headers,
      queryParameters: queryParameters,
      data: data,
      file: file,
      fileKey: fileKey
    );
  }

  Future<dynamic> _request(
    ApiData apiData,
    String method,
    String apiMethod,
    {
      Map<String, String> headers,
      Map<String, dynamic> queryParameters,
      dynamic data,
      File file,
      String fileKey = 'file'
    }
  ) async {
    dynamic dataToSend = data;

    if (data is! Map<String, dynamic> && file != null) {
      throw 'file not empty, data must be Map<String, dynamic>';
    }

    if (file != null) {
      dataToSend = _createFileFormData(data, file, fileKey);
    }

    try {
      return await _rawRequest(
        apiData,
        method,
        apiMethod,
        headers: headers,
        data: dataToSend,
        queryParameters: queryParameters
      );
    } on AuthException {
      if (dataToSend is FormData) {
        dataToSend = _createFileFormData(data, file, fileKey);
      }

      return await _rawRequest(
        await relogin(),
        method,
        apiMethod,
        headers: headers,
        data: dataToSend,
        queryParameters: queryParameters
      );
    }
  }

  Dio _createDio(ApiData apiData, String method, [Map<String, String> headers = const {}]) {
    String appName = Strings.appName;

    if (headers == null) headers = {};

    if (apiData.token != null) {
      headers.addAll({
        'Authorization': '$authSchema token=${apiData.token}'
      });
    }

    headers.addAll({
      'Accept': 'application/json',
      appName: '$version',
      HttpHeaders.userAgentHeader: '$appName/$version ${FlutterUserAgent.userAgent}',
    });

    return Dio(BaseOptions(
      method: method,
      baseUrl: apiData.url,
      connectTimeout: 100000,
      receiveTimeout: 100000,
      headers: headers,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ));
  }

  static void _onDioError(DioError e) {
    if (e.response != null) {
      final int statusCode = e.response.statusCode;
      final dynamic body = e.response.data;

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
      if (e.error is SocketException || e.error is HandshakeException || e.type == DioErrorType.CONNECT_TIMEOUT) {
        throw ApiConnException();
      }

      throw e;
    }
  }

  FormData _createFileFormData(Map<String, dynamic> data, File file, String fileKey) {
    Map<String, dynamic> dataToAdd = data;
    dataToAdd[fileKey] = MultipartFile.fromBytes(file.readAsBytesSync(), filename: file.path.split('/').last);

    return FormData.fromMap(dataToAdd);
  }

  Future<dynamic> _rawRequest(
    ApiData apiData,
    String method,
    String apiMethod,
    {
      Map<String, String> headers,
      Map<String, dynamic> queryParameters,
      data
    }
  ) async {
    Dio dio = _createDio(apiData, method, headers);

    try {
      return (await dio.request(apiMethod, data: data, queryParameters: queryParameters)).data;
    } on DioError catch(e) {
      _onDioError(e);
    }
  }

  Future<ApiData> _authenticate(ApiData apiData) async {
    dynamic response = await _rawRequest(
      apiData,
      'POST',
      'v1/authenticate',
      headers: {
        'Authorization': '$authSchema login=${apiData.login},password=${apiData.password}'
      }
    );

    return ApiData(
      login: apiData.login,
      password: apiData.password,
      url: apiData.url,
      token: response['token']
    );
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
