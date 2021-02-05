import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:delman/app/app.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/services/api.dart';

class AppError implements Exception {
  final String message;

  AppError(this.message);
}

class AppState extends ChangeNotifier {
  final App app;
  AppData _appData;
  List<DeliveryPoint> _deliveryPoints = [];
  List<Delivery> _deliveries = [];
  List<OrderLine> _orderLines = [];
  List<Order> _orders = [];
  List<Payment> _payments = [];

  User _user;

  bool get newVersionAvailable {
    String currentVersion = app.version;
    String remoteVersion = user.version;

    return remoteVersion != null && Version.parse(remoteVersion) > Version.parse(currentVersion);
  }

  String get fullVersion => app.version + '+' + app.buildNumber;

  AppState({@required this.app}) {
    _appData = app.appDataRepo.getAppData();
    _user = app.userRepo.getUser();

    loadData();
  }

  AppData get appData => _appData;
  List<DeliveryPoint> get deliveryPoints => _deliveryPoints;
  List<Delivery> get deliveries => _deliveries;
  List<OrderLine> get orderLines => _orderLines;
  List<Order> get orders => _orders;
  List<Payment> get payments => _payments;
  User get user => _user;

  Future<void> loadData() async {
    _deliveryPoints = await app.deliveryPointRepo.getDeliveryPoints();
    _deliveries = await app.deliveryRepo.getDeliveries();
    _orderLines = await app.orderLineRepo.getOrderLines();
    _orders = await app.orderRepo.getOrders();
    _payments = await app.paymentRepo.getPayments();

    notifyListeners();
  }

  Future<void> getData() async {
    await loadUserData();

    try {
      dynamic data = await app.api.getData();

      await _setDeliveryPoints(data['deliveryPoints']);
      await _setDeliveries(data['deliveries']);
      await _setOrderLines(data['orderLines']);
      await _setOrders(data['orders']);
      await _setPayments(data['payments']);
      await _setAppData(AppData(lastSyncTime: DateTime.now()));
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    notifyListeners();
  }

  Future<void> clearData() async {
    await deleteUser();
    await _setDeliveryPoints([]);
    await _setDeliveries([]);
    await _setOrderLines([]);
    await _setOrders([]);
    await _setPayments([]);
    await _setAppData(AppData());

    notifyListeners();
  }

  Future<void> _setAppData(AppData appData) async {
    await app.appDataRepo.setAppData(appData);
    _appData = appData;
  }

  Future<void> _setDeliveryPoints(List<DeliveryPoint> deliveryPoints) async {
    _deliveryPoints = deliveryPoints;
    await app.deliveryPointRepo.reloadDeliveryPoints(deliveryPoints);
  }

  Future<void> _setDeliveries(List<Delivery> deliveries) async {
    _deliveries = deliveries;
    await app.deliveryRepo.reloadDeliveries(deliveries);
  }

  Future<void> _setOrderLines(List<OrderLine> orderLines) async {
    _orderLines = orderLines;
    await app.orderLineRepo.reloadOrderLines(orderLines);
  }

  Future<void> _setOrders(List<Order> orders) async {
    _orders = orders;
    await app.orderRepo.reloadOrders(orders);
  }

  Future<void> _setPayments(List<Payment> payments) async {
    _payments = payments;
    await app.paymentRepo.reloadPayments(payments);
  }

  Future<void> loadUserData() async {
    try {
      User user = await app.api.getUserData();
      await app.userRepo.setUser(user);
      _user = user;
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    notifyListeners();
  }

  Future<void> deleteUser() async {
    _user = await app.userRepo.resetUser();
    notifyListeners();
  }

  Future<DeliveryPoint> arriveAtDeliveryPoint(DeliveryPoint deliveryPoint, Location location) async {
    DeliveryPoint updatedDeliveryPoint = deliveryPoint.copyWith(factArrival: DateTime.now());

    try {
      await app.api.arriveAtDeliveryPoint(updatedDeliveryPoint, location);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _deliveryPoints.removeWhere((e) => e.id == updatedDeliveryPoint.id);
    _deliveryPoints.add(updatedDeliveryPoint);
    await app.deliveryPointRepo.updateDeliveryPoint(updatedDeliveryPoint);

    notifyListeners();

    return updatedDeliveryPoint;
  }

  Future<DeliveryPoint> departFromDeliveryPoint(DeliveryPoint deliveryPoint, Location location) async {
    DeliveryPoint updatedDeliveryPoint = deliveryPoint.copyWith(factDeparture: DateTime.now());

    _deliveryPoints.removeWhere((e) => e.id == updatedDeliveryPoint.id);
    _deliveryPoints.add(updatedDeliveryPoint);
    await app.deliveryPointRepo.updateDeliveryPoint(updatedDeliveryPoint);

    notifyListeners();

    return updatedDeliveryPoint;
  }

  Future<Order> cancelOrder(Order order, Location location) async {
    Order updatedOrder = order.copyWith(canceled: 1, finished: 1);

    try {
      await app.api.cancelOrder(order, location);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _orders.removeWhere((e) => e.id == updatedOrder.id);
    _orders.add(updatedOrder);
    await app.orderRepo.updateOrder(updatedOrder);

    if (!_orders.any((e) => e.deliveryPointId == updatedOrder.deliveryPointId && !e.isFinished)) {
      await departFromDeliveryPoint(_deliveryPoints.firstWhere((e) => e.id == updatedOrder.deliveryPointId), location);
    }

    notifyListeners();

    return updatedOrder;
  }

  Future<Order> confirmOrder(Order order, List<OrderLine> orderLines, Location location) async {
    Order updatedOrder = order.copyWith(finished: 1);
    List<OrderLine> updatedOrderLines = orderLines;

    try {
      await app.api.confirmOrder(order, orderLines, location);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _orders.removeWhere((e) => e.id == updatedOrder.id);
    _orders.add(updatedOrder);
    await app.orderRepo.updateOrder(updatedOrder);

    _orderLines.removeWhere((e) => e.orderId == updatedOrder.id);
    _orderLines.addAll(updatedOrderLines);
    await app.orderLineRepo.updateOrderLines(updatedOrderLines);

    if (!_orders.any((e) => e.deliveryPointId == updatedOrder.deliveryPointId && !e.isFinished)) {
      await departFromDeliveryPoint(_deliveryPoints.firstWhere((e) => e.id == updatedOrder.deliveryPointId), location);
    }

    notifyListeners();

    return updatedOrder;
  }

  Future<void> acceptPayment(Payment payment, Map<dynamic, dynamic> transaction, Location location) async {
    try {
      await app.api.acceptPayment(payment, transaction, location);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _payments.add(payment);
    await app.paymentRepo.addPayments([payment]);

    notifyListeners();
  }

  Future<void> login(String url, String login, String password) async {
    try {
      await app.api.login(url, login, password);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await loadUserData();
  }

  Future<void> logout() async {
    try {
      await app.api.logout();
      await clearData();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> resetPassword(String url, String login) async {
    try {
      await app.api.resetPassword(url, login);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<Map<String, dynamic>> getPaymentCredentials() async {
    try {
      return await app.api.getPaymentCredentials();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> sendLogs() async {
    try {
      List<Log> logs = await FLog.getAllLogsByFilter(filterType: FilterType.TODAY);

      await app.api.saveLogs(logs, app.deviceModel, app.osVersion);
      await FLog.clearLogs();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> _reportError(dynamic error, dynamic stackTrace) async {
    await app.reportError(error, stackTrace);
    FLog.error(
      methodName: Trace.current().frames[1].member.split('.')[1],
      text: error.toString(),
      exception: error,
      stacktrace: stackTrace
    );
  }
}
