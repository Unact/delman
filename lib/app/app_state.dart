import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:quiver/core.dart';
import 'package:stack_trace/stack_trace.dart';

import 'package:delman/app/app.dart';
import 'package:delman/app/constants/strings.dart';
import 'package:delman/app/entities/entities.dart';
import 'package:delman/app/repositories/repositories.dart';
import 'package:delman/app/services/api.dart';
import 'package:delman/app/services/storage.dart';
import 'package:delman/app/utils/geo_loc.dart';

class AppError implements Exception {
  final String message;

  AppError(this.message);
}

class AppState extends ChangeNotifier {
  final App app;
  late AppData _appData;
  late User _user;
  List<DeliveryPoint> _deliveryPoints = [];
  List<Delivery> _deliveries = [];
  List<OrderLine> _orderLines = [];
  List<Order> _orders = [];
  List<DeliveryPointOrder> _deliveryPointOrders = [];
  List<OrderStorage> _orderStorages = [];
  List<Payment> _payments = [];
  List<OrderInfo> _orderInfoList = [];

  final Api api;
  final AppDataRepository appDataRepo;
  final DeliveryPointOrderRepository deliveryPointOrderRepo;
  final DeliveryPointRepository deliveryPointRepo;
  final DeliveryRepository deliveryRepo;
  final OrderInfoRepository orderInfoRepo;
  final OrderLineRepository orderLineRepo;
  final OrderRepository orderRepo;
  final OrderStorageRepository orderStorageRepo;
  final PaymentRepository paymentRepo;
  final UserRepository userRepo;

  bool get newVersionAvailable {
    String currentVersion = app.version;
    String? remoteVersion = user.version;

    return remoteVersion != null && Version.parse(remoteVersion) > Version.parse(currentVersion);
  }

  String get fullVersion => app.version + '+' + app.buildNumber;

  AppState({required this.app}) :
    api = Api.instance!,
    appDataRepo = AppDataRepository(storage: Storage.instance!),
    deliveryPointRepo = DeliveryPointRepository(storage: Storage.instance!),
    deliveryRepo = DeliveryRepository(storage: Storage.instance!),
    orderInfoRepo = OrderInfoRepository(storage: Storage.instance!),
    orderLineRepo = OrderLineRepository(storage: Storage.instance!),
    orderRepo = OrderRepository(storage: Storage.instance!),
    deliveryPointOrderRepo = DeliveryPointOrderRepository(storage: Storage.instance!),
    orderStorageRepo = OrderStorageRepository(storage: Storage.instance!),
    paymentRepo = PaymentRepository(storage: Storage.instance!),
    userRepo = UserRepository(storage: Storage.instance!)
  {
    loadData();
  }

  AppData get appData => _appData;
  List<DeliveryPoint> get deliveryPoints => _deliveryPoints;
  List<Delivery> get deliveries => _deliveries;
  List<OrderLine> get orderLines => _orderLines;
  List<Order> get orders => _orders;
  List<Payment> get payments => _payments;
  List<DeliveryPointOrder> get deliveryPointOrders => _deliveryPointOrders;
  List<OrderStorage> get orderStorages => _orderStorages;
  List<OrderInfo> get orderInfoList => _orderInfoList;
  User get user => _user;

  Future<void> loadData() async {
    _appData = appDataRepo.getAppData();
    _user = userRepo.getUser();
    _deliveryPoints = await deliveryPointRepo.getRecords();
    _deliveries = await deliveryRepo.getRecords();
    _orderLines = await orderLineRepo.getRecords();
    _orders = await orderRepo.getRecords();
    _deliveryPointOrders = await deliveryPointOrderRepo.getRecords();
    _orderStorages = await orderStorageRepo.getRecords();
    _payments = await paymentRepo.getRecords();
    _orderInfoList = await orderInfoRepo.getRecords();

    notifyListeners();
  }

  Future<void> getData() async {
    Location? location = await GeoLoc.getCurrentLocation();

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    await loadUserData();

    try {
      GetDataResponse data = await api.getData();

      await _setDeliveryPoints(data.deliveryPoints);
      await _setDeliveries(data.deliveries);
      await _setOrderInfoList(data.orderInfoList);
      await _setOrderLines(data.orderLines);
      await _setOrders(data.orders);
      await _setDeliveryPointOrders(data.deliveryPointOrders);
      await _setOrderStorages(data.orderStorages);
      await _setPayments(data.payments);
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
    await _setDeliveryPointOrders([]);
    await _setOrderStorages([]);
    await _setPayments([]);
    await _setOrderInfoList([]);
    await _setAppData(AppData());

    notifyListeners();
  }

  Future<void> _setAppData(AppData appData) async {
    await appDataRepo.setAppData(appData);
    _appData = appData;
  }

  Future<void> _setDeliveryPoints(List<DeliveryPoint> deliveryPoints) async {
    _deliveryPoints = deliveryPoints;
    await deliveryPointRepo.reloadRecords(deliveryPoints);
  }

  Future<void> _setDeliveries(List<Delivery> deliveries) async {
    _deliveries = deliveries;
    await deliveryRepo.reloadRecords(deliveries);
  }

  Future<void> _setOrderLines(List<OrderLine> orderLines) async {
    _orderLines = orderLines;
    await orderLineRepo.reloadRecords(orderLines);
  }

  Future<void> _setOrders(List<Order> orders) async {
    _orders = orders;
    await orderRepo.reloadRecords(orders);
  }

  Future<void> _setDeliveryPointOrders(List<DeliveryPointOrder> deliveryPointOrders) async {
    _deliveryPointOrders = deliveryPointOrders;
    await deliveryPointOrderRepo.reloadRecords(deliveryPointOrders);
  }

  Future<void> _setOrderStorages(List<OrderStorage> orderStorages) async {
    _orderStorages = orderStorages;
    await orderStorageRepo.reloadRecords(orderStorages);
  }

  Future<void> _setPayments(List<Payment> payments) async {
    _payments = payments;
    await paymentRepo.reloadRecords(payments);
  }

  Future<void> _setOrderInfoList(List<OrderInfo> orderInfoList) async {
    _orderInfoList = orderInfoList;
    await orderInfoRepo.reloadRecords(orderInfoList);
  }

  Future<DeliveryPoint> _departFromDeliveryPoint(DeliveryPoint deliveryPoint, Location location) async {
    DeliveryPoint updatedDeliveryPoint = deliveryPoint.copyWith(factDeparture: Optional.fromNullable((DateTime.now())));

    _deliveryPoints.removeWhere((e) => e.id == updatedDeliveryPoint.id);
    _deliveryPoints.add(updatedDeliveryPoint);
    await deliveryPointRepo.updateDeliveryPoint(updatedDeliveryPoint);

    notifyListeners();

    return updatedDeliveryPoint;
  }

  Future<void> loadUserData() async {
    try {
      User user = await api.getUserData();
      await userRepo.setUser(user);
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
    _user = await userRepo.resetUser();
    notifyListeners();
  }

  Future<DeliveryPoint> arriveAtDeliveryPoint(DeliveryPoint deliveryPoint) async {
    Location? location = await GeoLoc.getCurrentLocation();
    DeliveryPoint updatedDeliveryPoint = deliveryPoint.copyWith(factArrival: Optional.fromNullable(DateTime.now()));

    if (!deliveryPoints.any((e) => e.id == deliveryPoint.id)) {
      throw AppError('Не найдена точка доставки');
    }

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    try {
      await api.arriveAtDeliveryPoint(updatedDeliveryPoint, location);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _deliveryPoints.removeWhere((e) => e.id == updatedDeliveryPoint.id);
    _deliveryPoints.add(updatedDeliveryPoint);
    await deliveryPointRepo.updateDeliveryPoint(updatedDeliveryPoint);

    notifyListeners();

    return updatedDeliveryPoint;
  }

  Future<DeliveryPointOrder> cancelOrder(DeliveryPointOrder deliveryPointOrder) async {
    if (!_deliveryPointOrders.any((e) => e.id == deliveryPointOrder.id)) {
      throw AppError('Не найден заказ');
    }

    Location? location = await GeoLoc.getCurrentLocation();
    DeliveryPointOrder updatedDeliveryPointOrder = deliveryPointOrder.copyWith(canceled: 1, finished: 1);

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    try {
      await api.cancelOrder(updatedDeliveryPointOrder, location);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _deliveryPointOrders.removeWhere((e) => e.id == updatedDeliveryPointOrder.id);
    _deliveryPointOrders.add(updatedDeliveryPointOrder);
    await deliveryPointOrderRepo.updateRecord(updatedDeliveryPointOrder);

    if (
      !_deliveryPointOrders.any((e) => e.deliveryPointId == updatedDeliveryPointOrder.deliveryPointId && !e.isFinished)
    ) {
      await _departFromDeliveryPoint(
        _deliveryPoints.firstWhere((e) => e.id == updatedDeliveryPointOrder.deliveryPointId),
        location
      );
    }

    notifyListeners();

    return updatedDeliveryPointOrder;
  }

  Future<DeliveryPointOrder> confirmOrder(DeliveryPointOrder deliveryPointOrder, List<OrderLine> orderLines) async {
    if (!_deliveryPointOrders.any((e) => e.id == deliveryPointOrder.id)) {
      throw AppError('Не найден заказ');
    }

    Location? location = await GeoLoc.getCurrentLocation();
    DeliveryPointOrder updatedDeliveryPointOrder = deliveryPointOrder.copyWith(finished: 1);
    List<OrderLine> updatedOrderLines = orderLines;

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    try {
      await api.confirmOrder(updatedDeliveryPointOrder, orderLines, location);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    Order updatedOrder = orders.firstWhere((e) => e.id == updatedDeliveryPointOrder.orderId).copyWith(
      storageId: Optional.fromNullable(updatedDeliveryPointOrder.isPickup ? user.storageId : null)
    );

    _orders.removeWhere((e) => e.id == updatedOrder.id);
    _orders.add(updatedOrder);
    await orderRepo.updateRecord(updatedOrder);

    _orderLines.removeWhere((e) => e.orderId == updatedOrder.id);
    _orderLines.addAll(updatedOrderLines);
    await orderLineRepo.updateRecords(updatedOrderLines);

    _deliveryPointOrders.removeWhere((e) => e.id == updatedDeliveryPointOrder.id);
    _deliveryPointOrders.add(updatedDeliveryPointOrder);
    await deliveryPointOrderRepo.updateRecord(updatedDeliveryPointOrder);

    if (
      !_deliveryPointOrders.any((e) => e.deliveryPointId == updatedDeliveryPointOrder.deliveryPointId && !e.isFinished)
    ) {
      await _departFromDeliveryPoint(
        _deliveryPoints.firstWhere((e) => e.id == updatedDeliveryPointOrder.deliveryPointId),
        location
      );
    }

    notifyListeners();

    return updatedDeliveryPointOrder;
  }

  Future<void> acceptPayment(Payment payment, Map<dynamic, dynamic>? transaction) async {
    Location? location = await GeoLoc.getCurrentLocation();

    if (location == null) {
      throw AppError('Для работы с приложением необходимо разрешить определение местоположения');
    }

    try {
      await api.acceptPayment(payment, transaction, location);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _payments.add(payment);
    await paymentRepo.addRecords([payment]);

    notifyListeners();
  }

  Future<void> acceptOrder(Order order) async {
    Order updatedOrder = order.copyWith(storageId: Optional.fromNullable(user.storageId));

    try {
      await api.acceptOrder(order);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _orders.removeWhere((e) => e.id == updatedOrder.id);
    _orders.add(updatedOrder);
    await orderRepo.updateRecord(updatedOrder);

    notifyListeners();
  }

  Future<void> transferOrder(Order order, OrderStorage orderStorage) async {
    Order updatedOrder = order.copyWith(storageId: Optional.fromNullable(null));

    try {
      await api.transferOrder(updatedOrder, orderStorage);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _orders.removeWhere((e) => e.id == updatedOrder.id);
    _orders.add(updatedOrder);
    await orderRepo.updateRecord(updatedOrder);

    notifyListeners();
  }

  Future<OrderInfo> addOrderInfo(Order order, String comment) async {
    OrderInfo newOrderInfo = OrderInfo(orderId: order.id, comment: comment, ts: DateTime.now());

    try {
      await api.addOrderInfo(newOrderInfo);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    _orderInfoList.add(newOrderInfo);
    await orderInfoRepo.addRecords([newOrderInfo]);

    notifyListeners();

    return newOrderInfo;
  }

  Future<void> closeDelivery() async {
    try {
      await api.closeDelivery();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }

    await getData();
  }

  Future<void> login(String url, String login, String password) async {
    try {
      await api.login(url, login, password);
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
      await api.logout();
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
      await api.resetPassword(url, login);
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<PaymentCredentials> getPaymentCredentials() async {
    try {
      return await api.getPaymentCredentials();
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

      await api.saveLogs(logs, app.deviceModel, app.osVersion);
      await FLog.clearLogs();
    } on ApiException catch(e) {
      throw AppError(e.errorMsg);
    } catch(e, trace) {
      _reportError(e, trace);
      throw AppError(Strings.genericErrorMsg);
    }
  }

  Future<void> _reportError(dynamic error, dynamic stackTrace) async {
    Frame methodFrame = Trace.current().frames.length > 1 ? Trace.current().frames[1] : Trace.current().frames[0];

    await app.reportError(error, stackTrace);
    FLog.error(
      methodName: methodFrame.member!.split('.')[1],
      text: error.toString(),
      exception: error,
      stacktrace: stackTrace
    );
  }
}
