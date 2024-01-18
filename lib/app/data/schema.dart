part of 'database.dart';

class Prefs extends Table {
  DateTimeColumn get lastSync => dateTime().nullable()();
}

@DataClassName("Delivery")
class Deliveries extends Table {
  IntColumn get id => integer().autoIncrement()();
  BoolColumn get active => boolean()();
  DateTimeColumn get deliveryDate => dateTime()();
}

class DeliveryPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deliveryId => integer().references(Deliveries, #id)();
  IntColumn get seq => integer()();
  DateTimeColumn get planArrival => dateTime()();
  DateTimeColumn get planDeparture => dateTime()();
  DateTimeColumn get factArrival => dateTime().nullable()();
  DateTimeColumn get factDeparture => dateTime().nullable()();
  TextColumn get addressName => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get sellerName => text().nullable()();
  TextColumn get buyerName => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get paymentTypeName => text().nullable()();
  TextColumn get deliveryTypeName => text().nullable()();
  TextColumn get pickupSellerName => text().nullable()();
  TextColumn get senderName => text().nullable()();
  TextColumn get senderPhone  => text().nullable()();
}

class DeliveryPointOrders extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deliveryPointId => integer().references(DeliveryPoints, #id)();
  IntColumn get orderId => integer().references(Orders, #id)();
  BoolColumn get canceled => boolean()();
  BoolColumn get finished => boolean()();
  BoolColumn get pickup => boolean()();
}

class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get deliveryDateTimeFrom => dateTime().nullable()();
  DateTimeColumn get deliveryDateTimeTo => dateTime().nullable()();
  DateTimeColumn get pickupDateTimeFrom => dateTime().nullable()();
  DateTimeColumn get pickupDateTimeTo => dateTime().nullable()();

  TextColumn get number => text()();
  TextColumn get trackingNumber => text()();
  TextColumn get senderName => text().nullable()();
  TextColumn get buyerName => text().nullable()();
  TextColumn get senderPhone => text().nullable()();
  TextColumn get buyerPhone => text().nullable()();
  TextColumn get comment => text().nullable()();
  TextColumn get deliveryTypeName => text()();
  TextColumn get pickupTypeName => text()();
  IntColumn get senderFloor => integer().nullable()();
  IntColumn get buyerFloor => integer().nullable()();
  TextColumn get senderFlat => text().nullable()();
  TextColumn get buyerFlat => text().nullable()();
  BoolColumn get senderElevator => boolean()();
  BoolColumn get buyerElevator => boolean()();
  TextColumn get paymentTypeName => text()();
  TextColumn get sellerName => text()();
  BoolColumn get documentsReturn => boolean()();
  TextColumn get deliveryAddressName => text()();
  TextColumn get pickupAddressName => text()();
  IntColumn get packages => integer()();
  BoolColumn get cardPaymentAllowed => boolean()();
  BoolColumn get needPayment => boolean()();
  BoolColumn get factsConfirmed => boolean()();
  IntColumn get storageId => integer().nullable().references(OrderStorages, #id)();
  IntColumn get deliveryLoadDuration => integer()();
  IntColumn get pickupLoadDuration => integer()();
  TextColumn get productArrivalName => text().nullable()();
  TextColumn get productArrivalQR => text().nullable()();
}

class OrderLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();

  TextColumn get name => text()();
  IntColumn get amount => integer()();
  RealColumn get price => real()();
  IntColumn get factAmount => integer().nullable()();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deliveryPointOrderId => integer().references(DeliveryPointOrders, #id)();
  RealColumn get summ => real()();
  TextColumn get transactionId => text().nullable()();
}

class OrderStorages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
}

class OrderInfoLines extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId => integer().references(Orders, #id)();
  TextColumn get comment => text()();
  DateTimeColumn get ts => dateTime()();
}

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  IntColumn get storageId => integer().references(OrderStorages, #id)();
  TextColumn get storageQR => text()();
  TextColumn get version => text()();
}
