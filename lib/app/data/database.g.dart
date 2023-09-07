// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DeliveriesTable extends Deliveries
    with TableInfo<$DeliveriesTable, Delivery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'));
  static const VerificationMeta _deliveryDateMeta =
      const VerificationMeta('deliveryDate');
  @override
  late final GeneratedColumn<DateTime> deliveryDate = GeneratedColumn<DateTime>(
      'delivery_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, active, deliveryDate];
  @override
  String get aliasedName => _alias ?? 'deliveries';
  @override
  String get actualTableName => 'deliveries';
  @override
  VerificationContext validateIntegrity(Insertable<Delivery> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    } else if (isInserting) {
      context.missing(_activeMeta);
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
          _deliveryDateMeta,
          deliveryDate.isAcceptableOrUnknown(
              data['delivery_date']!, _deliveryDateMeta));
    } else if (isInserting) {
      context.missing(_deliveryDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Delivery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Delivery(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      deliveryDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}delivery_date'])!,
    );
  }

  @override
  $DeliveriesTable createAlias(String alias) {
    return $DeliveriesTable(attachedDatabase, alias);
  }
}

class Delivery extends DataClass implements Insertable<Delivery> {
  final int id;
  final bool active;
  final DateTime deliveryDate;
  const Delivery(
      {required this.id, required this.active, required this.deliveryDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['active'] = Variable<bool>(active);
    map['delivery_date'] = Variable<DateTime>(deliveryDate);
    return map;
  }

  DeliveriesCompanion toCompanion(bool nullToAbsent) {
    return DeliveriesCompanion(
      id: Value(id),
      active: Value(active),
      deliveryDate: Value(deliveryDate),
    );
  }

  factory Delivery.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Delivery(
      id: serializer.fromJson<int>(json['id']),
      active: serializer.fromJson<bool>(json['active']),
      deliveryDate: serializer.fromJson<DateTime>(json['deliveryDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'active': serializer.toJson<bool>(active),
      'deliveryDate': serializer.toJson<DateTime>(deliveryDate),
    };
  }

  Delivery copyWith({int? id, bool? active, DateTime? deliveryDate}) =>
      Delivery(
        id: id ?? this.id,
        active: active ?? this.active,
        deliveryDate: deliveryDate ?? this.deliveryDate,
      );
  @override
  String toString() {
    return (StringBuffer('Delivery(')
          ..write('id: $id, ')
          ..write('active: $active, ')
          ..write('deliveryDate: $deliveryDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, active, deliveryDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Delivery &&
          other.id == this.id &&
          other.active == this.active &&
          other.deliveryDate == this.deliveryDate);
}

class DeliveriesCompanion extends UpdateCompanion<Delivery> {
  final Value<int> id;
  final Value<bool> active;
  final Value<DateTime> deliveryDate;
  const DeliveriesCompanion({
    this.id = const Value.absent(),
    this.active = const Value.absent(),
    this.deliveryDate = const Value.absent(),
  });
  DeliveriesCompanion.insert({
    this.id = const Value.absent(),
    required bool active,
    required DateTime deliveryDate,
  })  : active = Value(active),
        deliveryDate = Value(deliveryDate);
  static Insertable<Delivery> custom({
    Expression<int>? id,
    Expression<bool>? active,
    Expression<DateTime>? deliveryDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (active != null) 'active': active,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
    });
  }

  DeliveriesCompanion copyWith(
      {Value<int>? id, Value<bool>? active, Value<DateTime>? deliveryDate}) {
    return DeliveriesCompanion(
      id: id ?? this.id,
      active: active ?? this.active,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesCompanion(')
          ..write('id: $id, ')
          ..write('active: $active, ')
          ..write('deliveryDate: $deliveryDate')
          ..write(')'))
        .toString();
  }
}

class $DeliveryPointsTable extends DeliveryPoints
    with TableInfo<$DeliveryPointsTable, DeliveryPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deliveryIdMeta =
      const VerificationMeta('deliveryId');
  @override
  late final GeneratedColumn<int> deliveryId = GeneratedColumn<int>(
      'delivery_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES deliveries (id)'));
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
      'seq', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _planArrivalMeta =
      const VerificationMeta('planArrival');
  @override
  late final GeneratedColumn<DateTime> planArrival = GeneratedColumn<DateTime>(
      'plan_arrival', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _planDepartureMeta =
      const VerificationMeta('planDeparture');
  @override
  late final GeneratedColumn<DateTime> planDeparture =
      GeneratedColumn<DateTime>('plan_departure', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _factArrivalMeta =
      const VerificationMeta('factArrival');
  @override
  late final GeneratedColumn<DateTime> factArrival = GeneratedColumn<DateTime>(
      'fact_arrival', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _factDepartureMeta =
      const VerificationMeta('factDeparture');
  @override
  late final GeneratedColumn<DateTime> factDeparture =
      GeneratedColumn<DateTime>('fact_departure', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _addressNameMeta =
      const VerificationMeta('addressName');
  @override
  late final GeneratedColumn<String> addressName = GeneratedColumn<String>(
      'address_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _sellerNameMeta =
      const VerificationMeta('sellerName');
  @override
  late final GeneratedColumn<String> sellerName = GeneratedColumn<String>(
      'seller_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buyerNameMeta =
      const VerificationMeta('buyerName');
  @override
  late final GeneratedColumn<String> buyerName = GeneratedColumn<String>(
      'buyer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _paymentTypeNameMeta =
      const VerificationMeta('paymentTypeName');
  @override
  late final GeneratedColumn<String> paymentTypeName = GeneratedColumn<String>(
      'payment_type_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deliveryTypeNameMeta =
      const VerificationMeta('deliveryTypeName');
  @override
  late final GeneratedColumn<String> deliveryTypeName = GeneratedColumn<String>(
      'delivery_type_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pickupSellerNameMeta =
      const VerificationMeta('pickupSellerName');
  @override
  late final GeneratedColumn<String> pickupSellerName = GeneratedColumn<String>(
      'pickup_seller_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderNameMeta =
      const VerificationMeta('senderName');
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
      'sender_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderPhoneMeta =
      const VerificationMeta('senderPhone');
  @override
  late final GeneratedColumn<String> senderPhone = GeneratedColumn<String>(
      'sender_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deliveryId,
        seq,
        planArrival,
        planDeparture,
        factArrival,
        factDeparture,
        addressName,
        latitude,
        longitude,
        sellerName,
        buyerName,
        phone,
        paymentTypeName,
        deliveryTypeName,
        pickupSellerName,
        senderName,
        senderPhone
      ];
  @override
  String get aliasedName => _alias ?? 'delivery_points';
  @override
  String get actualTableName => 'delivery_points';
  @override
  VerificationContext validateIntegrity(Insertable<DeliveryPoint> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
          _deliveryIdMeta,
          deliveryId.isAcceptableOrUnknown(
              data['delivery_id']!, _deliveryIdMeta));
    } else if (isInserting) {
      context.missing(_deliveryIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
          _seqMeta, seq.isAcceptableOrUnknown(data['seq']!, _seqMeta));
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('plan_arrival')) {
      context.handle(
          _planArrivalMeta,
          planArrival.isAcceptableOrUnknown(
              data['plan_arrival']!, _planArrivalMeta));
    } else if (isInserting) {
      context.missing(_planArrivalMeta);
    }
    if (data.containsKey('plan_departure')) {
      context.handle(
          _planDepartureMeta,
          planDeparture.isAcceptableOrUnknown(
              data['plan_departure']!, _planDepartureMeta));
    } else if (isInserting) {
      context.missing(_planDepartureMeta);
    }
    if (data.containsKey('fact_arrival')) {
      context.handle(
          _factArrivalMeta,
          factArrival.isAcceptableOrUnknown(
              data['fact_arrival']!, _factArrivalMeta));
    }
    if (data.containsKey('fact_departure')) {
      context.handle(
          _factDepartureMeta,
          factDeparture.isAcceptableOrUnknown(
              data['fact_departure']!, _factDepartureMeta));
    }
    if (data.containsKey('address_name')) {
      context.handle(
          _addressNameMeta,
          addressName.isAcceptableOrUnknown(
              data['address_name']!, _addressNameMeta));
    } else if (isInserting) {
      context.missing(_addressNameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('seller_name')) {
      context.handle(
          _sellerNameMeta,
          sellerName.isAcceptableOrUnknown(
              data['seller_name']!, _sellerNameMeta));
    }
    if (data.containsKey('buyer_name')) {
      context.handle(_buyerNameMeta,
          buyerName.isAcceptableOrUnknown(data['buyer_name']!, _buyerNameMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('payment_type_name')) {
      context.handle(
          _paymentTypeNameMeta,
          paymentTypeName.isAcceptableOrUnknown(
              data['payment_type_name']!, _paymentTypeNameMeta));
    }
    if (data.containsKey('delivery_type_name')) {
      context.handle(
          _deliveryTypeNameMeta,
          deliveryTypeName.isAcceptableOrUnknown(
              data['delivery_type_name']!, _deliveryTypeNameMeta));
    }
    if (data.containsKey('pickup_seller_name')) {
      context.handle(
          _pickupSellerNameMeta,
          pickupSellerName.isAcceptableOrUnknown(
              data['pickup_seller_name']!, _pickupSellerNameMeta));
    }
    if (data.containsKey('sender_name')) {
      context.handle(
          _senderNameMeta,
          senderName.isAcceptableOrUnknown(
              data['sender_name']!, _senderNameMeta));
    }
    if (data.containsKey('sender_phone')) {
      context.handle(
          _senderPhoneMeta,
          senderPhone.isAcceptableOrUnknown(
              data['sender_phone']!, _senderPhoneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveryPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryPoint(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deliveryId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}delivery_id'])!,
      seq: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}seq'])!,
      planArrival: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}plan_arrival'])!,
      planDeparture: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}plan_departure'])!,
      factArrival: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}fact_arrival']),
      factDeparture: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}fact_departure']),
      addressName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address_name'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude'])!,
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude'])!,
      sellerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller_name']),
      buyerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer_name']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      paymentTypeName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}payment_type_name']),
      deliveryTypeName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}delivery_type_name']),
      pickupSellerName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pickup_seller_name']),
      senderName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_name']),
      senderPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_phone']),
    );
  }

  @override
  $DeliveryPointsTable createAlias(String alias) {
    return $DeliveryPointsTable(attachedDatabase, alias);
  }
}

class DeliveryPoint extends DataClass implements Insertable<DeliveryPoint> {
  final int id;
  final int deliveryId;
  final int seq;
  final DateTime planArrival;
  final DateTime planDeparture;
  final DateTime? factArrival;
  final DateTime? factDeparture;
  final String addressName;
  final double latitude;
  final double longitude;
  final String? sellerName;
  final String? buyerName;
  final String? phone;
  final String? paymentTypeName;
  final String? deliveryTypeName;
  final String? pickupSellerName;
  final String? senderName;
  final String? senderPhone;
  const DeliveryPoint(
      {required this.id,
      required this.deliveryId,
      required this.seq,
      required this.planArrival,
      required this.planDeparture,
      this.factArrival,
      this.factDeparture,
      required this.addressName,
      required this.latitude,
      required this.longitude,
      this.sellerName,
      this.buyerName,
      this.phone,
      this.paymentTypeName,
      this.deliveryTypeName,
      this.pickupSellerName,
      this.senderName,
      this.senderPhone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['delivery_id'] = Variable<int>(deliveryId);
    map['seq'] = Variable<int>(seq);
    map['plan_arrival'] = Variable<DateTime>(planArrival);
    map['plan_departure'] = Variable<DateTime>(planDeparture);
    if (!nullToAbsent || factArrival != null) {
      map['fact_arrival'] = Variable<DateTime>(factArrival);
    }
    if (!nullToAbsent || factDeparture != null) {
      map['fact_departure'] = Variable<DateTime>(factDeparture);
    }
    map['address_name'] = Variable<String>(addressName);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || sellerName != null) {
      map['seller_name'] = Variable<String>(sellerName);
    }
    if (!nullToAbsent || buyerName != null) {
      map['buyer_name'] = Variable<String>(buyerName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || paymentTypeName != null) {
      map['payment_type_name'] = Variable<String>(paymentTypeName);
    }
    if (!nullToAbsent || deliveryTypeName != null) {
      map['delivery_type_name'] = Variable<String>(deliveryTypeName);
    }
    if (!nullToAbsent || pickupSellerName != null) {
      map['pickup_seller_name'] = Variable<String>(pickupSellerName);
    }
    if (!nullToAbsent || senderName != null) {
      map['sender_name'] = Variable<String>(senderName);
    }
    if (!nullToAbsent || senderPhone != null) {
      map['sender_phone'] = Variable<String>(senderPhone);
    }
    return map;
  }

  DeliveryPointsCompanion toCompanion(bool nullToAbsent) {
    return DeliveryPointsCompanion(
      id: Value(id),
      deliveryId: Value(deliveryId),
      seq: Value(seq),
      planArrival: Value(planArrival),
      planDeparture: Value(planDeparture),
      factArrival: factArrival == null && nullToAbsent
          ? const Value.absent()
          : Value(factArrival),
      factDeparture: factDeparture == null && nullToAbsent
          ? const Value.absent()
          : Value(factDeparture),
      addressName: Value(addressName),
      latitude: Value(latitude),
      longitude: Value(longitude),
      sellerName: sellerName == null && nullToAbsent
          ? const Value.absent()
          : Value(sellerName),
      buyerName: buyerName == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerName),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      paymentTypeName: paymentTypeName == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentTypeName),
      deliveryTypeName: deliveryTypeName == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryTypeName),
      pickupSellerName: pickupSellerName == null && nullToAbsent
          ? const Value.absent()
          : Value(pickupSellerName),
      senderName: senderName == null && nullToAbsent
          ? const Value.absent()
          : Value(senderName),
      senderPhone: senderPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(senderPhone),
    );
  }

  factory DeliveryPoint.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryPoint(
      id: serializer.fromJson<int>(json['id']),
      deliveryId: serializer.fromJson<int>(json['deliveryId']),
      seq: serializer.fromJson<int>(json['seq']),
      planArrival: serializer.fromJson<DateTime>(json['planArrival']),
      planDeparture: serializer.fromJson<DateTime>(json['planDeparture']),
      factArrival: serializer.fromJson<DateTime?>(json['factArrival']),
      factDeparture: serializer.fromJson<DateTime?>(json['factDeparture']),
      addressName: serializer.fromJson<String>(json['addressName']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      sellerName: serializer.fromJson<String?>(json['sellerName']),
      buyerName: serializer.fromJson<String?>(json['buyerName']),
      phone: serializer.fromJson<String?>(json['phone']),
      paymentTypeName: serializer.fromJson<String?>(json['paymentTypeName']),
      deliveryTypeName: serializer.fromJson<String?>(json['deliveryTypeName']),
      pickupSellerName: serializer.fromJson<String?>(json['pickupSellerName']),
      senderName: serializer.fromJson<String?>(json['senderName']),
      senderPhone: serializer.fromJson<String?>(json['senderPhone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deliveryId': serializer.toJson<int>(deliveryId),
      'seq': serializer.toJson<int>(seq),
      'planArrival': serializer.toJson<DateTime>(planArrival),
      'planDeparture': serializer.toJson<DateTime>(planDeparture),
      'factArrival': serializer.toJson<DateTime?>(factArrival),
      'factDeparture': serializer.toJson<DateTime?>(factDeparture),
      'addressName': serializer.toJson<String>(addressName),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'sellerName': serializer.toJson<String?>(sellerName),
      'buyerName': serializer.toJson<String?>(buyerName),
      'phone': serializer.toJson<String?>(phone),
      'paymentTypeName': serializer.toJson<String?>(paymentTypeName),
      'deliveryTypeName': serializer.toJson<String?>(deliveryTypeName),
      'pickupSellerName': serializer.toJson<String?>(pickupSellerName),
      'senderName': serializer.toJson<String?>(senderName),
      'senderPhone': serializer.toJson<String?>(senderPhone),
    };
  }

  DeliveryPoint copyWith(
          {int? id,
          int? deliveryId,
          int? seq,
          DateTime? planArrival,
          DateTime? planDeparture,
          Value<DateTime?> factArrival = const Value.absent(),
          Value<DateTime?> factDeparture = const Value.absent(),
          String? addressName,
          double? latitude,
          double? longitude,
          Value<String?> sellerName = const Value.absent(),
          Value<String?> buyerName = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> paymentTypeName = const Value.absent(),
          Value<String?> deliveryTypeName = const Value.absent(),
          Value<String?> pickupSellerName = const Value.absent(),
          Value<String?> senderName = const Value.absent(),
          Value<String?> senderPhone = const Value.absent()}) =>
      DeliveryPoint(
        id: id ?? this.id,
        deliveryId: deliveryId ?? this.deliveryId,
        seq: seq ?? this.seq,
        planArrival: planArrival ?? this.planArrival,
        planDeparture: planDeparture ?? this.planDeparture,
        factArrival: factArrival.present ? factArrival.value : this.factArrival,
        factDeparture:
            factDeparture.present ? factDeparture.value : this.factDeparture,
        addressName: addressName ?? this.addressName,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        sellerName: sellerName.present ? sellerName.value : this.sellerName,
        buyerName: buyerName.present ? buyerName.value : this.buyerName,
        phone: phone.present ? phone.value : this.phone,
        paymentTypeName: paymentTypeName.present
            ? paymentTypeName.value
            : this.paymentTypeName,
        deliveryTypeName: deliveryTypeName.present
            ? deliveryTypeName.value
            : this.deliveryTypeName,
        pickupSellerName: pickupSellerName.present
            ? pickupSellerName.value
            : this.pickupSellerName,
        senderName: senderName.present ? senderName.value : this.senderName,
        senderPhone: senderPhone.present ? senderPhone.value : this.senderPhone,
      );
  @override
  String toString() {
    return (StringBuffer('DeliveryPoint(')
          ..write('id: $id, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('seq: $seq, ')
          ..write('planArrival: $planArrival, ')
          ..write('planDeparture: $planDeparture, ')
          ..write('factArrival: $factArrival, ')
          ..write('factDeparture: $factDeparture, ')
          ..write('addressName: $addressName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sellerName: $sellerName, ')
          ..write('buyerName: $buyerName, ')
          ..write('phone: $phone, ')
          ..write('paymentTypeName: $paymentTypeName, ')
          ..write('deliveryTypeName: $deliveryTypeName, ')
          ..write('pickupSellerName: $pickupSellerName, ')
          ..write('senderName: $senderName, ')
          ..write('senderPhone: $senderPhone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      deliveryId,
      seq,
      planArrival,
      planDeparture,
      factArrival,
      factDeparture,
      addressName,
      latitude,
      longitude,
      sellerName,
      buyerName,
      phone,
      paymentTypeName,
      deliveryTypeName,
      pickupSellerName,
      senderName,
      senderPhone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryPoint &&
          other.id == this.id &&
          other.deliveryId == this.deliveryId &&
          other.seq == this.seq &&
          other.planArrival == this.planArrival &&
          other.planDeparture == this.planDeparture &&
          other.factArrival == this.factArrival &&
          other.factDeparture == this.factDeparture &&
          other.addressName == this.addressName &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.sellerName == this.sellerName &&
          other.buyerName == this.buyerName &&
          other.phone == this.phone &&
          other.paymentTypeName == this.paymentTypeName &&
          other.deliveryTypeName == this.deliveryTypeName &&
          other.pickupSellerName == this.pickupSellerName &&
          other.senderName == this.senderName &&
          other.senderPhone == this.senderPhone);
}

class DeliveryPointsCompanion extends UpdateCompanion<DeliveryPoint> {
  final Value<int> id;
  final Value<int> deliveryId;
  final Value<int> seq;
  final Value<DateTime> planArrival;
  final Value<DateTime> planDeparture;
  final Value<DateTime?> factArrival;
  final Value<DateTime?> factDeparture;
  final Value<String> addressName;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String?> sellerName;
  final Value<String?> buyerName;
  final Value<String?> phone;
  final Value<String?> paymentTypeName;
  final Value<String?> deliveryTypeName;
  final Value<String?> pickupSellerName;
  final Value<String?> senderName;
  final Value<String?> senderPhone;
  const DeliveryPointsCompanion({
    this.id = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.seq = const Value.absent(),
    this.planArrival = const Value.absent(),
    this.planDeparture = const Value.absent(),
    this.factArrival = const Value.absent(),
    this.factDeparture = const Value.absent(),
    this.addressName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.sellerName = const Value.absent(),
    this.buyerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.paymentTypeName = const Value.absent(),
    this.deliveryTypeName = const Value.absent(),
    this.pickupSellerName = const Value.absent(),
    this.senderName = const Value.absent(),
    this.senderPhone = const Value.absent(),
  });
  DeliveryPointsCompanion.insert({
    this.id = const Value.absent(),
    required int deliveryId,
    required int seq,
    required DateTime planArrival,
    required DateTime planDeparture,
    this.factArrival = const Value.absent(),
    this.factDeparture = const Value.absent(),
    required String addressName,
    required double latitude,
    required double longitude,
    this.sellerName = const Value.absent(),
    this.buyerName = const Value.absent(),
    this.phone = const Value.absent(),
    this.paymentTypeName = const Value.absent(),
    this.deliveryTypeName = const Value.absent(),
    this.pickupSellerName = const Value.absent(),
    this.senderName = const Value.absent(),
    this.senderPhone = const Value.absent(),
  })  : deliveryId = Value(deliveryId),
        seq = Value(seq),
        planArrival = Value(planArrival),
        planDeparture = Value(planDeparture),
        addressName = Value(addressName),
        latitude = Value(latitude),
        longitude = Value(longitude);
  static Insertable<DeliveryPoint> custom({
    Expression<int>? id,
    Expression<int>? deliveryId,
    Expression<int>? seq,
    Expression<DateTime>? planArrival,
    Expression<DateTime>? planDeparture,
    Expression<DateTime>? factArrival,
    Expression<DateTime>? factDeparture,
    Expression<String>? addressName,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? sellerName,
    Expression<String>? buyerName,
    Expression<String>? phone,
    Expression<String>? paymentTypeName,
    Expression<String>? deliveryTypeName,
    Expression<String>? pickupSellerName,
    Expression<String>? senderName,
    Expression<String>? senderPhone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (seq != null) 'seq': seq,
      if (planArrival != null) 'plan_arrival': planArrival,
      if (planDeparture != null) 'plan_departure': planDeparture,
      if (factArrival != null) 'fact_arrival': factArrival,
      if (factDeparture != null) 'fact_departure': factDeparture,
      if (addressName != null) 'address_name': addressName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (sellerName != null) 'seller_name': sellerName,
      if (buyerName != null) 'buyer_name': buyerName,
      if (phone != null) 'phone': phone,
      if (paymentTypeName != null) 'payment_type_name': paymentTypeName,
      if (deliveryTypeName != null) 'delivery_type_name': deliveryTypeName,
      if (pickupSellerName != null) 'pickup_seller_name': pickupSellerName,
      if (senderName != null) 'sender_name': senderName,
      if (senderPhone != null) 'sender_phone': senderPhone,
    });
  }

  DeliveryPointsCompanion copyWith(
      {Value<int>? id,
      Value<int>? deliveryId,
      Value<int>? seq,
      Value<DateTime>? planArrival,
      Value<DateTime>? planDeparture,
      Value<DateTime?>? factArrival,
      Value<DateTime?>? factDeparture,
      Value<String>? addressName,
      Value<double>? latitude,
      Value<double>? longitude,
      Value<String?>? sellerName,
      Value<String?>? buyerName,
      Value<String?>? phone,
      Value<String?>? paymentTypeName,
      Value<String?>? deliveryTypeName,
      Value<String?>? pickupSellerName,
      Value<String?>? senderName,
      Value<String?>? senderPhone}) {
    return DeliveryPointsCompanion(
      id: id ?? this.id,
      deliveryId: deliveryId ?? this.deliveryId,
      seq: seq ?? this.seq,
      planArrival: planArrival ?? this.planArrival,
      planDeparture: planDeparture ?? this.planDeparture,
      factArrival: factArrival ?? this.factArrival,
      factDeparture: factDeparture ?? this.factDeparture,
      addressName: addressName ?? this.addressName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      sellerName: sellerName ?? this.sellerName,
      buyerName: buyerName ?? this.buyerName,
      phone: phone ?? this.phone,
      paymentTypeName: paymentTypeName ?? this.paymentTypeName,
      deliveryTypeName: deliveryTypeName ?? this.deliveryTypeName,
      pickupSellerName: pickupSellerName ?? this.pickupSellerName,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<int>(deliveryId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (planArrival.present) {
      map['plan_arrival'] = Variable<DateTime>(planArrival.value);
    }
    if (planDeparture.present) {
      map['plan_departure'] = Variable<DateTime>(planDeparture.value);
    }
    if (factArrival.present) {
      map['fact_arrival'] = Variable<DateTime>(factArrival.value);
    }
    if (factDeparture.present) {
      map['fact_departure'] = Variable<DateTime>(factDeparture.value);
    }
    if (addressName.present) {
      map['address_name'] = Variable<String>(addressName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (sellerName.present) {
      map['seller_name'] = Variable<String>(sellerName.value);
    }
    if (buyerName.present) {
      map['buyer_name'] = Variable<String>(buyerName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (paymentTypeName.present) {
      map['payment_type_name'] = Variable<String>(paymentTypeName.value);
    }
    if (deliveryTypeName.present) {
      map['delivery_type_name'] = Variable<String>(deliveryTypeName.value);
    }
    if (pickupSellerName.present) {
      map['pickup_seller_name'] = Variable<String>(pickupSellerName.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (senderPhone.present) {
      map['sender_phone'] = Variable<String>(senderPhone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryPointsCompanion(')
          ..write('id: $id, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('seq: $seq, ')
          ..write('planArrival: $planArrival, ')
          ..write('planDeparture: $planDeparture, ')
          ..write('factArrival: $factArrival, ')
          ..write('factDeparture: $factDeparture, ')
          ..write('addressName: $addressName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('sellerName: $sellerName, ')
          ..write('buyerName: $buyerName, ')
          ..write('phone: $phone, ')
          ..write('paymentTypeName: $paymentTypeName, ')
          ..write('deliveryTypeName: $deliveryTypeName, ')
          ..write('pickupSellerName: $pickupSellerName, ')
          ..write('senderName: $senderName, ')
          ..write('senderPhone: $senderPhone')
          ..write(')'))
        .toString();
  }
}

class $OrderStoragesTable extends OrderStorages
    with TableInfo<$OrderStoragesTable, OrderStorage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderStoragesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? 'order_storages';
  @override
  String get actualTableName => 'order_storages';
  @override
  VerificationContext validateIntegrity(Insertable<OrderStorage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderStorage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderStorage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $OrderStoragesTable createAlias(String alias) {
    return $OrderStoragesTable(attachedDatabase, alias);
  }
}

class OrderStorage extends DataClass implements Insertable<OrderStorage> {
  final int id;
  final String name;
  const OrderStorage({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  OrderStoragesCompanion toCompanion(bool nullToAbsent) {
    return OrderStoragesCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory OrderStorage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderStorage(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  OrderStorage copyWith({int? id, String? name}) => OrderStorage(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  @override
  String toString() {
    return (StringBuffer('OrderStorage(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderStorage && other.id == this.id && other.name == this.name);
}

class OrderStoragesCompanion extends UpdateCompanion<OrderStorage> {
  final Value<int> id;
  final Value<String> name;
  const OrderStoragesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  OrderStoragesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<OrderStorage> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  OrderStoragesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return OrderStoragesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderStoragesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deliveryDateTimeFromMeta =
      const VerificationMeta('deliveryDateTimeFrom');
  @override
  late final GeneratedColumn<DateTime> deliveryDateTimeFrom =
      GeneratedColumn<DateTime>('delivery_date_time_from', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _deliveryDateTimeToMeta =
      const VerificationMeta('deliveryDateTimeTo');
  @override
  late final GeneratedColumn<DateTime> deliveryDateTimeTo =
      GeneratedColumn<DateTime>('delivery_date_time_to', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pickupDateTimeFromMeta =
      const VerificationMeta('pickupDateTimeFrom');
  @override
  late final GeneratedColumn<DateTime> pickupDateTimeFrom =
      GeneratedColumn<DateTime>('pickup_date_time_from', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _pickupDateTimeToMeta =
      const VerificationMeta('pickupDateTimeTo');
  @override
  late final GeneratedColumn<DateTime> pickupDateTimeTo =
      GeneratedColumn<DateTime>('pickup_date_time_to', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trackingNumberMeta =
      const VerificationMeta('trackingNumber');
  @override
  late final GeneratedColumn<String> trackingNumber = GeneratedColumn<String>(
      'tracking_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderNameMeta =
      const VerificationMeta('senderName');
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
      'sender_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buyerNameMeta =
      const VerificationMeta('buyerName');
  @override
  late final GeneratedColumn<String> buyerName = GeneratedColumn<String>(
      'buyer_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderPhoneMeta =
      const VerificationMeta('senderPhone');
  @override
  late final GeneratedColumn<String> senderPhone = GeneratedColumn<String>(
      'sender_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buyerPhoneMeta =
      const VerificationMeta('buyerPhone');
  @override
  late final GeneratedColumn<String> buyerPhone = GeneratedColumn<String>(
      'buyer_phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deliveryTypeNameMeta =
      const VerificationMeta('deliveryTypeName');
  @override
  late final GeneratedColumn<String> deliveryTypeName = GeneratedColumn<String>(
      'delivery_type_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pickupTypeNameMeta =
      const VerificationMeta('pickupTypeName');
  @override
  late final GeneratedColumn<String> pickupTypeName = GeneratedColumn<String>(
      'pickup_type_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _senderFloorMeta =
      const VerificationMeta('senderFloor');
  @override
  late final GeneratedColumn<int> senderFloor = GeneratedColumn<int>(
      'sender_floor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _buyerFloorMeta =
      const VerificationMeta('buyerFloor');
  @override
  late final GeneratedColumn<int> buyerFloor = GeneratedColumn<int>(
      'buyer_floor', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _senderFlatMeta =
      const VerificationMeta('senderFlat');
  @override
  late final GeneratedColumn<String> senderFlat = GeneratedColumn<String>(
      'sender_flat', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _buyerFlatMeta =
      const VerificationMeta('buyerFlat');
  @override
  late final GeneratedColumn<String> buyerFlat = GeneratedColumn<String>(
      'buyer_flat', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _senderElevatorMeta =
      const VerificationMeta('senderElevator');
  @override
  late final GeneratedColumn<bool> senderElevator = GeneratedColumn<bool>(
      'sender_elevator', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sender_elevator" IN (0, 1))'));
  static const VerificationMeta _buyerElevatorMeta =
      const VerificationMeta('buyerElevator');
  @override
  late final GeneratedColumn<bool> buyerElevator = GeneratedColumn<bool>(
      'buyer_elevator', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("buyer_elevator" IN (0, 1))'));
  static const VerificationMeta _paymentTypeNameMeta =
      const VerificationMeta('paymentTypeName');
  @override
  late final GeneratedColumn<String> paymentTypeName = GeneratedColumn<String>(
      'payment_type_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sellerNameMeta =
      const VerificationMeta('sellerName');
  @override
  late final GeneratedColumn<String> sellerName = GeneratedColumn<String>(
      'seller_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentsReturnMeta =
      const VerificationMeta('documentsReturn');
  @override
  late final GeneratedColumn<bool> documentsReturn = GeneratedColumn<bool>(
      'documents_return', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("documents_return" IN (0, 1))'));
  static const VerificationMeta _deliveryAddressNameMeta =
      const VerificationMeta('deliveryAddressName');
  @override
  late final GeneratedColumn<String> deliveryAddressName =
      GeneratedColumn<String>('delivery_address_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pickupAddressNameMeta =
      const VerificationMeta('pickupAddressName');
  @override
  late final GeneratedColumn<String> pickupAddressName =
      GeneratedColumn<String>('pickup_address_name', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _packagesMeta =
      const VerificationMeta('packages');
  @override
  late final GeneratedColumn<int> packages = GeneratedColumn<int>(
      'packages', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _cardPaymentAllowedMeta =
      const VerificationMeta('cardPaymentAllowed');
  @override
  late final GeneratedColumn<bool> cardPaymentAllowed = GeneratedColumn<bool>(
      'card_payment_allowed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("card_payment_allowed" IN (0, 1))'));
  static const VerificationMeta _needPaymentMeta =
      const VerificationMeta('needPayment');
  @override
  late final GeneratedColumn<bool> needPayment = GeneratedColumn<bool>(
      'need_payment', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("need_payment" IN (0, 1))'));
  static const VerificationMeta _factsConfirmedMeta =
      const VerificationMeta('factsConfirmed');
  @override
  late final GeneratedColumn<bool> factsConfirmed = GeneratedColumn<bool>(
      'facts_confirmed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("facts_confirmed" IN (0, 1))'));
  static const VerificationMeta _storageIdMeta =
      const VerificationMeta('storageId');
  @override
  late final GeneratedColumn<int> storageId = GeneratedColumn<int>(
      'storage_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES order_storages (id)'));
  static const VerificationMeta _deliveryLoadDurationMeta =
      const VerificationMeta('deliveryLoadDuration');
  @override
  late final GeneratedColumn<int> deliveryLoadDuration = GeneratedColumn<int>(
      'delivery_load_duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pickupLoadDurationMeta =
      const VerificationMeta('pickupLoadDuration');
  @override
  late final GeneratedColumn<int> pickupLoadDuration = GeneratedColumn<int>(
      'pickup_load_duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productArrivalNameMeta =
      const VerificationMeta('productArrivalName');
  @override
  late final GeneratedColumn<String> productArrivalName =
      GeneratedColumn<String>('product_arrival_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productArrivalQRMeta =
      const VerificationMeta('productArrivalQR');
  @override
  late final GeneratedColumn<String> productArrivalQR = GeneratedColumn<String>(
      'product_arrival_q_r', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deliveryDateTimeFrom,
        deliveryDateTimeTo,
        pickupDateTimeFrom,
        pickupDateTimeTo,
        number,
        trackingNumber,
        senderName,
        buyerName,
        senderPhone,
        buyerPhone,
        comment,
        deliveryTypeName,
        pickupTypeName,
        senderFloor,
        buyerFloor,
        senderFlat,
        buyerFlat,
        senderElevator,
        buyerElevator,
        paymentTypeName,
        sellerName,
        documentsReturn,
        deliveryAddressName,
        pickupAddressName,
        packages,
        cardPaymentAllowed,
        needPayment,
        factsConfirmed,
        storageId,
        deliveryLoadDuration,
        pickupLoadDuration,
        productArrivalName,
        productArrivalQR
      ];
  @override
  String get aliasedName => _alias ?? 'orders';
  @override
  String get actualTableName => 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<Order> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delivery_date_time_from')) {
      context.handle(
          _deliveryDateTimeFromMeta,
          deliveryDateTimeFrom.isAcceptableOrUnknown(
              data['delivery_date_time_from']!, _deliveryDateTimeFromMeta));
    }
    if (data.containsKey('delivery_date_time_to')) {
      context.handle(
          _deliveryDateTimeToMeta,
          deliveryDateTimeTo.isAcceptableOrUnknown(
              data['delivery_date_time_to']!, _deliveryDateTimeToMeta));
    }
    if (data.containsKey('pickup_date_time_from')) {
      context.handle(
          _pickupDateTimeFromMeta,
          pickupDateTimeFrom.isAcceptableOrUnknown(
              data['pickup_date_time_from']!, _pickupDateTimeFromMeta));
    }
    if (data.containsKey('pickup_date_time_to')) {
      context.handle(
          _pickupDateTimeToMeta,
          pickupDateTimeTo.isAcceptableOrUnknown(
              data['pickup_date_time_to']!, _pickupDateTimeToMeta));
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('tracking_number')) {
      context.handle(
          _trackingNumberMeta,
          trackingNumber.isAcceptableOrUnknown(
              data['tracking_number']!, _trackingNumberMeta));
    } else if (isInserting) {
      context.missing(_trackingNumberMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
          _senderNameMeta,
          senderName.isAcceptableOrUnknown(
              data['sender_name']!, _senderNameMeta));
    }
    if (data.containsKey('buyer_name')) {
      context.handle(_buyerNameMeta,
          buyerName.isAcceptableOrUnknown(data['buyer_name']!, _buyerNameMeta));
    }
    if (data.containsKey('sender_phone')) {
      context.handle(
          _senderPhoneMeta,
          senderPhone.isAcceptableOrUnknown(
              data['sender_phone']!, _senderPhoneMeta));
    }
    if (data.containsKey('buyer_phone')) {
      context.handle(
          _buyerPhoneMeta,
          buyerPhone.isAcceptableOrUnknown(
              data['buyer_phone']!, _buyerPhoneMeta));
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('delivery_type_name')) {
      context.handle(
          _deliveryTypeNameMeta,
          deliveryTypeName.isAcceptableOrUnknown(
              data['delivery_type_name']!, _deliveryTypeNameMeta));
    } else if (isInserting) {
      context.missing(_deliveryTypeNameMeta);
    }
    if (data.containsKey('pickup_type_name')) {
      context.handle(
          _pickupTypeNameMeta,
          pickupTypeName.isAcceptableOrUnknown(
              data['pickup_type_name']!, _pickupTypeNameMeta));
    } else if (isInserting) {
      context.missing(_pickupTypeNameMeta);
    }
    if (data.containsKey('sender_floor')) {
      context.handle(
          _senderFloorMeta,
          senderFloor.isAcceptableOrUnknown(
              data['sender_floor']!, _senderFloorMeta));
    }
    if (data.containsKey('buyer_floor')) {
      context.handle(
          _buyerFloorMeta,
          buyerFloor.isAcceptableOrUnknown(
              data['buyer_floor']!, _buyerFloorMeta));
    }
    if (data.containsKey('sender_flat')) {
      context.handle(
          _senderFlatMeta,
          senderFlat.isAcceptableOrUnknown(
              data['sender_flat']!, _senderFlatMeta));
    }
    if (data.containsKey('buyer_flat')) {
      context.handle(_buyerFlatMeta,
          buyerFlat.isAcceptableOrUnknown(data['buyer_flat']!, _buyerFlatMeta));
    }
    if (data.containsKey('sender_elevator')) {
      context.handle(
          _senderElevatorMeta,
          senderElevator.isAcceptableOrUnknown(
              data['sender_elevator']!, _senderElevatorMeta));
    } else if (isInserting) {
      context.missing(_senderElevatorMeta);
    }
    if (data.containsKey('buyer_elevator')) {
      context.handle(
          _buyerElevatorMeta,
          buyerElevator.isAcceptableOrUnknown(
              data['buyer_elevator']!, _buyerElevatorMeta));
    } else if (isInserting) {
      context.missing(_buyerElevatorMeta);
    }
    if (data.containsKey('payment_type_name')) {
      context.handle(
          _paymentTypeNameMeta,
          paymentTypeName.isAcceptableOrUnknown(
              data['payment_type_name']!, _paymentTypeNameMeta));
    } else if (isInserting) {
      context.missing(_paymentTypeNameMeta);
    }
    if (data.containsKey('seller_name')) {
      context.handle(
          _sellerNameMeta,
          sellerName.isAcceptableOrUnknown(
              data['seller_name']!, _sellerNameMeta));
    } else if (isInserting) {
      context.missing(_sellerNameMeta);
    }
    if (data.containsKey('documents_return')) {
      context.handle(
          _documentsReturnMeta,
          documentsReturn.isAcceptableOrUnknown(
              data['documents_return']!, _documentsReturnMeta));
    } else if (isInserting) {
      context.missing(_documentsReturnMeta);
    }
    if (data.containsKey('delivery_address_name')) {
      context.handle(
          _deliveryAddressNameMeta,
          deliveryAddressName.isAcceptableOrUnknown(
              data['delivery_address_name']!, _deliveryAddressNameMeta));
    } else if (isInserting) {
      context.missing(_deliveryAddressNameMeta);
    }
    if (data.containsKey('pickup_address_name')) {
      context.handle(
          _pickupAddressNameMeta,
          pickupAddressName.isAcceptableOrUnknown(
              data['pickup_address_name']!, _pickupAddressNameMeta));
    } else if (isInserting) {
      context.missing(_pickupAddressNameMeta);
    }
    if (data.containsKey('packages')) {
      context.handle(_packagesMeta,
          packages.isAcceptableOrUnknown(data['packages']!, _packagesMeta));
    } else if (isInserting) {
      context.missing(_packagesMeta);
    }
    if (data.containsKey('card_payment_allowed')) {
      context.handle(
          _cardPaymentAllowedMeta,
          cardPaymentAllowed.isAcceptableOrUnknown(
              data['card_payment_allowed']!, _cardPaymentAllowedMeta));
    } else if (isInserting) {
      context.missing(_cardPaymentAllowedMeta);
    }
    if (data.containsKey('need_payment')) {
      context.handle(
          _needPaymentMeta,
          needPayment.isAcceptableOrUnknown(
              data['need_payment']!, _needPaymentMeta));
    } else if (isInserting) {
      context.missing(_needPaymentMeta);
    }
    if (data.containsKey('facts_confirmed')) {
      context.handle(
          _factsConfirmedMeta,
          factsConfirmed.isAcceptableOrUnknown(
              data['facts_confirmed']!, _factsConfirmedMeta));
    } else if (isInserting) {
      context.missing(_factsConfirmedMeta);
    }
    if (data.containsKey('storage_id')) {
      context.handle(_storageIdMeta,
          storageId.isAcceptableOrUnknown(data['storage_id']!, _storageIdMeta));
    }
    if (data.containsKey('delivery_load_duration')) {
      context.handle(
          _deliveryLoadDurationMeta,
          deliveryLoadDuration.isAcceptableOrUnknown(
              data['delivery_load_duration']!, _deliveryLoadDurationMeta));
    } else if (isInserting) {
      context.missing(_deliveryLoadDurationMeta);
    }
    if (data.containsKey('pickup_load_duration')) {
      context.handle(
          _pickupLoadDurationMeta,
          pickupLoadDuration.isAcceptableOrUnknown(
              data['pickup_load_duration']!, _pickupLoadDurationMeta));
    } else if (isInserting) {
      context.missing(_pickupLoadDurationMeta);
    }
    if (data.containsKey('product_arrival_name')) {
      context.handle(
          _productArrivalNameMeta,
          productArrivalName.isAcceptableOrUnknown(
              data['product_arrival_name']!, _productArrivalNameMeta));
    }
    if (data.containsKey('product_arrival_q_r')) {
      context.handle(
          _productArrivalQRMeta,
          productArrivalQR.isAcceptableOrUnknown(
              data['product_arrival_q_r']!, _productArrivalQRMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deliveryDateTimeFrom: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}delivery_date_time_from']),
      deliveryDateTimeTo: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}delivery_date_time_to']),
      pickupDateTimeFrom: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}pickup_date_time_from']),
      pickupDateTimeTo: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}pickup_date_time_to']),
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
      trackingNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}tracking_number'])!,
      senderName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_name']),
      buyerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer_name']),
      senderPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_phone']),
      buyerPhone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer_phone']),
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
      deliveryTypeName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}delivery_type_name'])!,
      pickupTypeName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pickup_type_name'])!,
      senderFloor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sender_floor']),
      buyerFloor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}buyer_floor']),
      senderFlat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_flat']),
      buyerFlat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}buyer_flat']),
      senderElevator: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sender_elevator'])!,
      buyerElevator: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}buyer_elevator'])!,
      paymentTypeName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}payment_type_name'])!,
      sellerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seller_name'])!,
      documentsReturn: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}documents_return'])!,
      deliveryAddressName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}delivery_address_name'])!,
      pickupAddressName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}pickup_address_name'])!,
      packages: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}packages'])!,
      cardPaymentAllowed: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}card_payment_allowed'])!,
      needPayment: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}need_payment'])!,
      factsConfirmed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}facts_confirmed'])!,
      storageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}storage_id']),
      deliveryLoadDuration: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}delivery_load_duration'])!,
      pickupLoadDuration: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}pickup_load_duration'])!,
      productArrivalName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}product_arrival_name']),
      productArrivalQR: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}product_arrival_q_r']),
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final int id;
  final DateTime? deliveryDateTimeFrom;
  final DateTime? deliveryDateTimeTo;
  final DateTime? pickupDateTimeFrom;
  final DateTime? pickupDateTimeTo;
  final String number;
  final String trackingNumber;
  final String? senderName;
  final String? buyerName;
  final String? senderPhone;
  final String? buyerPhone;
  final String? comment;
  final String deliveryTypeName;
  final String pickupTypeName;
  final int? senderFloor;
  final int? buyerFloor;
  final String? senderFlat;
  final String? buyerFlat;
  final bool senderElevator;
  final bool buyerElevator;
  final String paymentTypeName;
  final String sellerName;
  final bool documentsReturn;
  final String deliveryAddressName;
  final String pickupAddressName;
  final int packages;
  final bool cardPaymentAllowed;
  final bool needPayment;
  final bool factsConfirmed;
  final int? storageId;
  final int deliveryLoadDuration;
  final int pickupLoadDuration;
  final String? productArrivalName;
  final String? productArrivalQR;
  const Order(
      {required this.id,
      this.deliveryDateTimeFrom,
      this.deliveryDateTimeTo,
      this.pickupDateTimeFrom,
      this.pickupDateTimeTo,
      required this.number,
      required this.trackingNumber,
      this.senderName,
      this.buyerName,
      this.senderPhone,
      this.buyerPhone,
      this.comment,
      required this.deliveryTypeName,
      required this.pickupTypeName,
      this.senderFloor,
      this.buyerFloor,
      this.senderFlat,
      this.buyerFlat,
      required this.senderElevator,
      required this.buyerElevator,
      required this.paymentTypeName,
      required this.sellerName,
      required this.documentsReturn,
      required this.deliveryAddressName,
      required this.pickupAddressName,
      required this.packages,
      required this.cardPaymentAllowed,
      required this.needPayment,
      required this.factsConfirmed,
      this.storageId,
      required this.deliveryLoadDuration,
      required this.pickupLoadDuration,
      this.productArrivalName,
      this.productArrivalQR});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || deliveryDateTimeFrom != null) {
      map['delivery_date_time_from'] = Variable<DateTime>(deliveryDateTimeFrom);
    }
    if (!nullToAbsent || deliveryDateTimeTo != null) {
      map['delivery_date_time_to'] = Variable<DateTime>(deliveryDateTimeTo);
    }
    if (!nullToAbsent || pickupDateTimeFrom != null) {
      map['pickup_date_time_from'] = Variable<DateTime>(pickupDateTimeFrom);
    }
    if (!nullToAbsent || pickupDateTimeTo != null) {
      map['pickup_date_time_to'] = Variable<DateTime>(pickupDateTimeTo);
    }
    map['number'] = Variable<String>(number);
    map['tracking_number'] = Variable<String>(trackingNumber);
    if (!nullToAbsent || senderName != null) {
      map['sender_name'] = Variable<String>(senderName);
    }
    if (!nullToAbsent || buyerName != null) {
      map['buyer_name'] = Variable<String>(buyerName);
    }
    if (!nullToAbsent || senderPhone != null) {
      map['sender_phone'] = Variable<String>(senderPhone);
    }
    if (!nullToAbsent || buyerPhone != null) {
      map['buyer_phone'] = Variable<String>(buyerPhone);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['delivery_type_name'] = Variable<String>(deliveryTypeName);
    map['pickup_type_name'] = Variable<String>(pickupTypeName);
    if (!nullToAbsent || senderFloor != null) {
      map['sender_floor'] = Variable<int>(senderFloor);
    }
    if (!nullToAbsent || buyerFloor != null) {
      map['buyer_floor'] = Variable<int>(buyerFloor);
    }
    if (!nullToAbsent || senderFlat != null) {
      map['sender_flat'] = Variable<String>(senderFlat);
    }
    if (!nullToAbsent || buyerFlat != null) {
      map['buyer_flat'] = Variable<String>(buyerFlat);
    }
    map['sender_elevator'] = Variable<bool>(senderElevator);
    map['buyer_elevator'] = Variable<bool>(buyerElevator);
    map['payment_type_name'] = Variable<String>(paymentTypeName);
    map['seller_name'] = Variable<String>(sellerName);
    map['documents_return'] = Variable<bool>(documentsReturn);
    map['delivery_address_name'] = Variable<String>(deliveryAddressName);
    map['pickup_address_name'] = Variable<String>(pickupAddressName);
    map['packages'] = Variable<int>(packages);
    map['card_payment_allowed'] = Variable<bool>(cardPaymentAllowed);
    map['need_payment'] = Variable<bool>(needPayment);
    map['facts_confirmed'] = Variable<bool>(factsConfirmed);
    if (!nullToAbsent || storageId != null) {
      map['storage_id'] = Variable<int>(storageId);
    }
    map['delivery_load_duration'] = Variable<int>(deliveryLoadDuration);
    map['pickup_load_duration'] = Variable<int>(pickupLoadDuration);
    if (!nullToAbsent || productArrivalName != null) {
      map['product_arrival_name'] = Variable<String>(productArrivalName);
    }
    if (!nullToAbsent || productArrivalQR != null) {
      map['product_arrival_q_r'] = Variable<String>(productArrivalQR);
    }
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      deliveryDateTimeFrom: deliveryDateTimeFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryDateTimeFrom),
      deliveryDateTimeTo: deliveryDateTimeTo == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryDateTimeTo),
      pickupDateTimeFrom: pickupDateTimeFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(pickupDateTimeFrom),
      pickupDateTimeTo: pickupDateTimeTo == null && nullToAbsent
          ? const Value.absent()
          : Value(pickupDateTimeTo),
      number: Value(number),
      trackingNumber: Value(trackingNumber),
      senderName: senderName == null && nullToAbsent
          ? const Value.absent()
          : Value(senderName),
      buyerName: buyerName == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerName),
      senderPhone: senderPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(senderPhone),
      buyerPhone: buyerPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerPhone),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      deliveryTypeName: Value(deliveryTypeName),
      pickupTypeName: Value(pickupTypeName),
      senderFloor: senderFloor == null && nullToAbsent
          ? const Value.absent()
          : Value(senderFloor),
      buyerFloor: buyerFloor == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerFloor),
      senderFlat: senderFlat == null && nullToAbsent
          ? const Value.absent()
          : Value(senderFlat),
      buyerFlat: buyerFlat == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerFlat),
      senderElevator: Value(senderElevator),
      buyerElevator: Value(buyerElevator),
      paymentTypeName: Value(paymentTypeName),
      sellerName: Value(sellerName),
      documentsReturn: Value(documentsReturn),
      deliveryAddressName: Value(deliveryAddressName),
      pickupAddressName: Value(pickupAddressName),
      packages: Value(packages),
      cardPaymentAllowed: Value(cardPaymentAllowed),
      needPayment: Value(needPayment),
      factsConfirmed: Value(factsConfirmed),
      storageId: storageId == null && nullToAbsent
          ? const Value.absent()
          : Value(storageId),
      deliveryLoadDuration: Value(deliveryLoadDuration),
      pickupLoadDuration: Value(pickupLoadDuration),
      productArrivalName: productArrivalName == null && nullToAbsent
          ? const Value.absent()
          : Value(productArrivalName),
      productArrivalQR: productArrivalQR == null && nullToAbsent
          ? const Value.absent()
          : Value(productArrivalQR),
    );
  }

  factory Order.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<int>(json['id']),
      deliveryDateTimeFrom:
          serializer.fromJson<DateTime?>(json['deliveryDateTimeFrom']),
      deliveryDateTimeTo:
          serializer.fromJson<DateTime?>(json['deliveryDateTimeTo']),
      pickupDateTimeFrom:
          serializer.fromJson<DateTime?>(json['pickupDateTimeFrom']),
      pickupDateTimeTo:
          serializer.fromJson<DateTime?>(json['pickupDateTimeTo']),
      number: serializer.fromJson<String>(json['number']),
      trackingNumber: serializer.fromJson<String>(json['trackingNumber']),
      senderName: serializer.fromJson<String?>(json['senderName']),
      buyerName: serializer.fromJson<String?>(json['buyerName']),
      senderPhone: serializer.fromJson<String?>(json['senderPhone']),
      buyerPhone: serializer.fromJson<String?>(json['buyerPhone']),
      comment: serializer.fromJson<String?>(json['comment']),
      deliveryTypeName: serializer.fromJson<String>(json['deliveryTypeName']),
      pickupTypeName: serializer.fromJson<String>(json['pickupTypeName']),
      senderFloor: serializer.fromJson<int?>(json['senderFloor']),
      buyerFloor: serializer.fromJson<int?>(json['buyerFloor']),
      senderFlat: serializer.fromJson<String?>(json['senderFlat']),
      buyerFlat: serializer.fromJson<String?>(json['buyerFlat']),
      senderElevator: serializer.fromJson<bool>(json['senderElevator']),
      buyerElevator: serializer.fromJson<bool>(json['buyerElevator']),
      paymentTypeName: serializer.fromJson<String>(json['paymentTypeName']),
      sellerName: serializer.fromJson<String>(json['sellerName']),
      documentsReturn: serializer.fromJson<bool>(json['documentsReturn']),
      deliveryAddressName:
          serializer.fromJson<String>(json['deliveryAddressName']),
      pickupAddressName: serializer.fromJson<String>(json['pickupAddressName']),
      packages: serializer.fromJson<int>(json['packages']),
      cardPaymentAllowed: serializer.fromJson<bool>(json['cardPaymentAllowed']),
      needPayment: serializer.fromJson<bool>(json['needPayment']),
      factsConfirmed: serializer.fromJson<bool>(json['factsConfirmed']),
      storageId: serializer.fromJson<int?>(json['storageId']),
      deliveryLoadDuration:
          serializer.fromJson<int>(json['deliveryLoadDuration']),
      pickupLoadDuration: serializer.fromJson<int>(json['pickupLoadDuration']),
      productArrivalName:
          serializer.fromJson<String?>(json['productArrivalName']),
      productArrivalQR: serializer.fromJson<String?>(json['productArrivalQR']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deliveryDateTimeFrom':
          serializer.toJson<DateTime?>(deliveryDateTimeFrom),
      'deliveryDateTimeTo': serializer.toJson<DateTime?>(deliveryDateTimeTo),
      'pickupDateTimeFrom': serializer.toJson<DateTime?>(pickupDateTimeFrom),
      'pickupDateTimeTo': serializer.toJson<DateTime?>(pickupDateTimeTo),
      'number': serializer.toJson<String>(number),
      'trackingNumber': serializer.toJson<String>(trackingNumber),
      'senderName': serializer.toJson<String?>(senderName),
      'buyerName': serializer.toJson<String?>(buyerName),
      'senderPhone': serializer.toJson<String?>(senderPhone),
      'buyerPhone': serializer.toJson<String?>(buyerPhone),
      'comment': serializer.toJson<String?>(comment),
      'deliveryTypeName': serializer.toJson<String>(deliveryTypeName),
      'pickupTypeName': serializer.toJson<String>(pickupTypeName),
      'senderFloor': serializer.toJson<int?>(senderFloor),
      'buyerFloor': serializer.toJson<int?>(buyerFloor),
      'senderFlat': serializer.toJson<String?>(senderFlat),
      'buyerFlat': serializer.toJson<String?>(buyerFlat),
      'senderElevator': serializer.toJson<bool>(senderElevator),
      'buyerElevator': serializer.toJson<bool>(buyerElevator),
      'paymentTypeName': serializer.toJson<String>(paymentTypeName),
      'sellerName': serializer.toJson<String>(sellerName),
      'documentsReturn': serializer.toJson<bool>(documentsReturn),
      'deliveryAddressName': serializer.toJson<String>(deliveryAddressName),
      'pickupAddressName': serializer.toJson<String>(pickupAddressName),
      'packages': serializer.toJson<int>(packages),
      'cardPaymentAllowed': serializer.toJson<bool>(cardPaymentAllowed),
      'needPayment': serializer.toJson<bool>(needPayment),
      'factsConfirmed': serializer.toJson<bool>(factsConfirmed),
      'storageId': serializer.toJson<int?>(storageId),
      'deliveryLoadDuration': serializer.toJson<int>(deliveryLoadDuration),
      'pickupLoadDuration': serializer.toJson<int>(pickupLoadDuration),
      'productArrivalName': serializer.toJson<String?>(productArrivalName),
      'productArrivalQR': serializer.toJson<String?>(productArrivalQR),
    };
  }

  Order copyWith(
          {int? id,
          Value<DateTime?> deliveryDateTimeFrom = const Value.absent(),
          Value<DateTime?> deliveryDateTimeTo = const Value.absent(),
          Value<DateTime?> pickupDateTimeFrom = const Value.absent(),
          Value<DateTime?> pickupDateTimeTo = const Value.absent(),
          String? number,
          String? trackingNumber,
          Value<String?> senderName = const Value.absent(),
          Value<String?> buyerName = const Value.absent(),
          Value<String?> senderPhone = const Value.absent(),
          Value<String?> buyerPhone = const Value.absent(),
          Value<String?> comment = const Value.absent(),
          String? deliveryTypeName,
          String? pickupTypeName,
          Value<int?> senderFloor = const Value.absent(),
          Value<int?> buyerFloor = const Value.absent(),
          Value<String?> senderFlat = const Value.absent(),
          Value<String?> buyerFlat = const Value.absent(),
          bool? senderElevator,
          bool? buyerElevator,
          String? paymentTypeName,
          String? sellerName,
          bool? documentsReturn,
          String? deliveryAddressName,
          String? pickupAddressName,
          int? packages,
          bool? cardPaymentAllowed,
          bool? needPayment,
          bool? factsConfirmed,
          Value<int?> storageId = const Value.absent(),
          int? deliveryLoadDuration,
          int? pickupLoadDuration,
          Value<String?> productArrivalName = const Value.absent(),
          Value<String?> productArrivalQR = const Value.absent()}) =>
      Order(
        id: id ?? this.id,
        deliveryDateTimeFrom: deliveryDateTimeFrom.present
            ? deliveryDateTimeFrom.value
            : this.deliveryDateTimeFrom,
        deliveryDateTimeTo: deliveryDateTimeTo.present
            ? deliveryDateTimeTo.value
            : this.deliveryDateTimeTo,
        pickupDateTimeFrom: pickupDateTimeFrom.present
            ? pickupDateTimeFrom.value
            : this.pickupDateTimeFrom,
        pickupDateTimeTo: pickupDateTimeTo.present
            ? pickupDateTimeTo.value
            : this.pickupDateTimeTo,
        number: number ?? this.number,
        trackingNumber: trackingNumber ?? this.trackingNumber,
        senderName: senderName.present ? senderName.value : this.senderName,
        buyerName: buyerName.present ? buyerName.value : this.buyerName,
        senderPhone: senderPhone.present ? senderPhone.value : this.senderPhone,
        buyerPhone: buyerPhone.present ? buyerPhone.value : this.buyerPhone,
        comment: comment.present ? comment.value : this.comment,
        deliveryTypeName: deliveryTypeName ?? this.deliveryTypeName,
        pickupTypeName: pickupTypeName ?? this.pickupTypeName,
        senderFloor: senderFloor.present ? senderFloor.value : this.senderFloor,
        buyerFloor: buyerFloor.present ? buyerFloor.value : this.buyerFloor,
        senderFlat: senderFlat.present ? senderFlat.value : this.senderFlat,
        buyerFlat: buyerFlat.present ? buyerFlat.value : this.buyerFlat,
        senderElevator: senderElevator ?? this.senderElevator,
        buyerElevator: buyerElevator ?? this.buyerElevator,
        paymentTypeName: paymentTypeName ?? this.paymentTypeName,
        sellerName: sellerName ?? this.sellerName,
        documentsReturn: documentsReturn ?? this.documentsReturn,
        deliveryAddressName: deliveryAddressName ?? this.deliveryAddressName,
        pickupAddressName: pickupAddressName ?? this.pickupAddressName,
        packages: packages ?? this.packages,
        cardPaymentAllowed: cardPaymentAllowed ?? this.cardPaymentAllowed,
        needPayment: needPayment ?? this.needPayment,
        factsConfirmed: factsConfirmed ?? this.factsConfirmed,
        storageId: storageId.present ? storageId.value : this.storageId,
        deliveryLoadDuration: deliveryLoadDuration ?? this.deliveryLoadDuration,
        pickupLoadDuration: pickupLoadDuration ?? this.pickupLoadDuration,
        productArrivalName: productArrivalName.present
            ? productArrivalName.value
            : this.productArrivalName,
        productArrivalQR: productArrivalQR.present
            ? productArrivalQR.value
            : this.productArrivalQR,
      );
  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('deliveryDateTimeFrom: $deliveryDateTimeFrom, ')
          ..write('deliveryDateTimeTo: $deliveryDateTimeTo, ')
          ..write('pickupDateTimeFrom: $pickupDateTimeFrom, ')
          ..write('pickupDateTimeTo: $pickupDateTimeTo, ')
          ..write('number: $number, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('senderName: $senderName, ')
          ..write('buyerName: $buyerName, ')
          ..write('senderPhone: $senderPhone, ')
          ..write('buyerPhone: $buyerPhone, ')
          ..write('comment: $comment, ')
          ..write('deliveryTypeName: $deliveryTypeName, ')
          ..write('pickupTypeName: $pickupTypeName, ')
          ..write('senderFloor: $senderFloor, ')
          ..write('buyerFloor: $buyerFloor, ')
          ..write('senderFlat: $senderFlat, ')
          ..write('buyerFlat: $buyerFlat, ')
          ..write('senderElevator: $senderElevator, ')
          ..write('buyerElevator: $buyerElevator, ')
          ..write('paymentTypeName: $paymentTypeName, ')
          ..write('sellerName: $sellerName, ')
          ..write('documentsReturn: $documentsReturn, ')
          ..write('deliveryAddressName: $deliveryAddressName, ')
          ..write('pickupAddressName: $pickupAddressName, ')
          ..write('packages: $packages, ')
          ..write('cardPaymentAllowed: $cardPaymentAllowed, ')
          ..write('needPayment: $needPayment, ')
          ..write('factsConfirmed: $factsConfirmed, ')
          ..write('storageId: $storageId, ')
          ..write('deliveryLoadDuration: $deliveryLoadDuration, ')
          ..write('pickupLoadDuration: $pickupLoadDuration, ')
          ..write('productArrivalName: $productArrivalName, ')
          ..write('productArrivalQR: $productArrivalQR')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        deliveryDateTimeFrom,
        deliveryDateTimeTo,
        pickupDateTimeFrom,
        pickupDateTimeTo,
        number,
        trackingNumber,
        senderName,
        buyerName,
        senderPhone,
        buyerPhone,
        comment,
        deliveryTypeName,
        pickupTypeName,
        senderFloor,
        buyerFloor,
        senderFlat,
        buyerFlat,
        senderElevator,
        buyerElevator,
        paymentTypeName,
        sellerName,
        documentsReturn,
        deliveryAddressName,
        pickupAddressName,
        packages,
        cardPaymentAllowed,
        needPayment,
        factsConfirmed,
        storageId,
        deliveryLoadDuration,
        pickupLoadDuration,
        productArrivalName,
        productArrivalQR
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.deliveryDateTimeFrom == this.deliveryDateTimeFrom &&
          other.deliveryDateTimeTo == this.deliveryDateTimeTo &&
          other.pickupDateTimeFrom == this.pickupDateTimeFrom &&
          other.pickupDateTimeTo == this.pickupDateTimeTo &&
          other.number == this.number &&
          other.trackingNumber == this.trackingNumber &&
          other.senderName == this.senderName &&
          other.buyerName == this.buyerName &&
          other.senderPhone == this.senderPhone &&
          other.buyerPhone == this.buyerPhone &&
          other.comment == this.comment &&
          other.deliveryTypeName == this.deliveryTypeName &&
          other.pickupTypeName == this.pickupTypeName &&
          other.senderFloor == this.senderFloor &&
          other.buyerFloor == this.buyerFloor &&
          other.senderFlat == this.senderFlat &&
          other.buyerFlat == this.buyerFlat &&
          other.senderElevator == this.senderElevator &&
          other.buyerElevator == this.buyerElevator &&
          other.paymentTypeName == this.paymentTypeName &&
          other.sellerName == this.sellerName &&
          other.documentsReturn == this.documentsReturn &&
          other.deliveryAddressName == this.deliveryAddressName &&
          other.pickupAddressName == this.pickupAddressName &&
          other.packages == this.packages &&
          other.cardPaymentAllowed == this.cardPaymentAllowed &&
          other.needPayment == this.needPayment &&
          other.factsConfirmed == this.factsConfirmed &&
          other.storageId == this.storageId &&
          other.deliveryLoadDuration == this.deliveryLoadDuration &&
          other.pickupLoadDuration == this.pickupLoadDuration &&
          other.productArrivalName == this.productArrivalName &&
          other.productArrivalQR == this.productArrivalQR);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<int> id;
  final Value<DateTime?> deliveryDateTimeFrom;
  final Value<DateTime?> deliveryDateTimeTo;
  final Value<DateTime?> pickupDateTimeFrom;
  final Value<DateTime?> pickupDateTimeTo;
  final Value<String> number;
  final Value<String> trackingNumber;
  final Value<String?> senderName;
  final Value<String?> buyerName;
  final Value<String?> senderPhone;
  final Value<String?> buyerPhone;
  final Value<String?> comment;
  final Value<String> deliveryTypeName;
  final Value<String> pickupTypeName;
  final Value<int?> senderFloor;
  final Value<int?> buyerFloor;
  final Value<String?> senderFlat;
  final Value<String?> buyerFlat;
  final Value<bool> senderElevator;
  final Value<bool> buyerElevator;
  final Value<String> paymentTypeName;
  final Value<String> sellerName;
  final Value<bool> documentsReturn;
  final Value<String> deliveryAddressName;
  final Value<String> pickupAddressName;
  final Value<int> packages;
  final Value<bool> cardPaymentAllowed;
  final Value<bool> needPayment;
  final Value<bool> factsConfirmed;
  final Value<int?> storageId;
  final Value<int> deliveryLoadDuration;
  final Value<int> pickupLoadDuration;
  final Value<String?> productArrivalName;
  final Value<String?> productArrivalQR;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.deliveryDateTimeFrom = const Value.absent(),
    this.deliveryDateTimeTo = const Value.absent(),
    this.pickupDateTimeFrom = const Value.absent(),
    this.pickupDateTimeTo = const Value.absent(),
    this.number = const Value.absent(),
    this.trackingNumber = const Value.absent(),
    this.senderName = const Value.absent(),
    this.buyerName = const Value.absent(),
    this.senderPhone = const Value.absent(),
    this.buyerPhone = const Value.absent(),
    this.comment = const Value.absent(),
    this.deliveryTypeName = const Value.absent(),
    this.pickupTypeName = const Value.absent(),
    this.senderFloor = const Value.absent(),
    this.buyerFloor = const Value.absent(),
    this.senderFlat = const Value.absent(),
    this.buyerFlat = const Value.absent(),
    this.senderElevator = const Value.absent(),
    this.buyerElevator = const Value.absent(),
    this.paymentTypeName = const Value.absent(),
    this.sellerName = const Value.absent(),
    this.documentsReturn = const Value.absent(),
    this.deliveryAddressName = const Value.absent(),
    this.pickupAddressName = const Value.absent(),
    this.packages = const Value.absent(),
    this.cardPaymentAllowed = const Value.absent(),
    this.needPayment = const Value.absent(),
    this.factsConfirmed = const Value.absent(),
    this.storageId = const Value.absent(),
    this.deliveryLoadDuration = const Value.absent(),
    this.pickupLoadDuration = const Value.absent(),
    this.productArrivalName = const Value.absent(),
    this.productArrivalQR = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    this.deliveryDateTimeFrom = const Value.absent(),
    this.deliveryDateTimeTo = const Value.absent(),
    this.pickupDateTimeFrom = const Value.absent(),
    this.pickupDateTimeTo = const Value.absent(),
    required String number,
    required String trackingNumber,
    this.senderName = const Value.absent(),
    this.buyerName = const Value.absent(),
    this.senderPhone = const Value.absent(),
    this.buyerPhone = const Value.absent(),
    this.comment = const Value.absent(),
    required String deliveryTypeName,
    required String pickupTypeName,
    this.senderFloor = const Value.absent(),
    this.buyerFloor = const Value.absent(),
    this.senderFlat = const Value.absent(),
    this.buyerFlat = const Value.absent(),
    required bool senderElevator,
    required bool buyerElevator,
    required String paymentTypeName,
    required String sellerName,
    required bool documentsReturn,
    required String deliveryAddressName,
    required String pickupAddressName,
    required int packages,
    required bool cardPaymentAllowed,
    required bool needPayment,
    required bool factsConfirmed,
    this.storageId = const Value.absent(),
    required int deliveryLoadDuration,
    required int pickupLoadDuration,
    this.productArrivalName = const Value.absent(),
    this.productArrivalQR = const Value.absent(),
  })  : number = Value(number),
        trackingNumber = Value(trackingNumber),
        deliveryTypeName = Value(deliveryTypeName),
        pickupTypeName = Value(pickupTypeName),
        senderElevator = Value(senderElevator),
        buyerElevator = Value(buyerElevator),
        paymentTypeName = Value(paymentTypeName),
        sellerName = Value(sellerName),
        documentsReturn = Value(documentsReturn),
        deliveryAddressName = Value(deliveryAddressName),
        pickupAddressName = Value(pickupAddressName),
        packages = Value(packages),
        cardPaymentAllowed = Value(cardPaymentAllowed),
        needPayment = Value(needPayment),
        factsConfirmed = Value(factsConfirmed),
        deliveryLoadDuration = Value(deliveryLoadDuration),
        pickupLoadDuration = Value(pickupLoadDuration);
  static Insertable<Order> custom({
    Expression<int>? id,
    Expression<DateTime>? deliveryDateTimeFrom,
    Expression<DateTime>? deliveryDateTimeTo,
    Expression<DateTime>? pickupDateTimeFrom,
    Expression<DateTime>? pickupDateTimeTo,
    Expression<String>? number,
    Expression<String>? trackingNumber,
    Expression<String>? senderName,
    Expression<String>? buyerName,
    Expression<String>? senderPhone,
    Expression<String>? buyerPhone,
    Expression<String>? comment,
    Expression<String>? deliveryTypeName,
    Expression<String>? pickupTypeName,
    Expression<int>? senderFloor,
    Expression<int>? buyerFloor,
    Expression<String>? senderFlat,
    Expression<String>? buyerFlat,
    Expression<bool>? senderElevator,
    Expression<bool>? buyerElevator,
    Expression<String>? paymentTypeName,
    Expression<String>? sellerName,
    Expression<bool>? documentsReturn,
    Expression<String>? deliveryAddressName,
    Expression<String>? pickupAddressName,
    Expression<int>? packages,
    Expression<bool>? cardPaymentAllowed,
    Expression<bool>? needPayment,
    Expression<bool>? factsConfirmed,
    Expression<int>? storageId,
    Expression<int>? deliveryLoadDuration,
    Expression<int>? pickupLoadDuration,
    Expression<String>? productArrivalName,
    Expression<String>? productArrivalQR,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deliveryDateTimeFrom != null)
        'delivery_date_time_from': deliveryDateTimeFrom,
      if (deliveryDateTimeTo != null)
        'delivery_date_time_to': deliveryDateTimeTo,
      if (pickupDateTimeFrom != null)
        'pickup_date_time_from': pickupDateTimeFrom,
      if (pickupDateTimeTo != null) 'pickup_date_time_to': pickupDateTimeTo,
      if (number != null) 'number': number,
      if (trackingNumber != null) 'tracking_number': trackingNumber,
      if (senderName != null) 'sender_name': senderName,
      if (buyerName != null) 'buyer_name': buyerName,
      if (senderPhone != null) 'sender_phone': senderPhone,
      if (buyerPhone != null) 'buyer_phone': buyerPhone,
      if (comment != null) 'comment': comment,
      if (deliveryTypeName != null) 'delivery_type_name': deliveryTypeName,
      if (pickupTypeName != null) 'pickup_type_name': pickupTypeName,
      if (senderFloor != null) 'sender_floor': senderFloor,
      if (buyerFloor != null) 'buyer_floor': buyerFloor,
      if (senderFlat != null) 'sender_flat': senderFlat,
      if (buyerFlat != null) 'buyer_flat': buyerFlat,
      if (senderElevator != null) 'sender_elevator': senderElevator,
      if (buyerElevator != null) 'buyer_elevator': buyerElevator,
      if (paymentTypeName != null) 'payment_type_name': paymentTypeName,
      if (sellerName != null) 'seller_name': sellerName,
      if (documentsReturn != null) 'documents_return': documentsReturn,
      if (deliveryAddressName != null)
        'delivery_address_name': deliveryAddressName,
      if (pickupAddressName != null) 'pickup_address_name': pickupAddressName,
      if (packages != null) 'packages': packages,
      if (cardPaymentAllowed != null)
        'card_payment_allowed': cardPaymentAllowed,
      if (needPayment != null) 'need_payment': needPayment,
      if (factsConfirmed != null) 'facts_confirmed': factsConfirmed,
      if (storageId != null) 'storage_id': storageId,
      if (deliveryLoadDuration != null)
        'delivery_load_duration': deliveryLoadDuration,
      if (pickupLoadDuration != null)
        'pickup_load_duration': pickupLoadDuration,
      if (productArrivalName != null)
        'product_arrival_name': productArrivalName,
      if (productArrivalQR != null) 'product_arrival_q_r': productArrivalQR,
    });
  }

  OrdersCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? deliveryDateTimeFrom,
      Value<DateTime?>? deliveryDateTimeTo,
      Value<DateTime?>? pickupDateTimeFrom,
      Value<DateTime?>? pickupDateTimeTo,
      Value<String>? number,
      Value<String>? trackingNumber,
      Value<String?>? senderName,
      Value<String?>? buyerName,
      Value<String?>? senderPhone,
      Value<String?>? buyerPhone,
      Value<String?>? comment,
      Value<String>? deliveryTypeName,
      Value<String>? pickupTypeName,
      Value<int?>? senderFloor,
      Value<int?>? buyerFloor,
      Value<String?>? senderFlat,
      Value<String?>? buyerFlat,
      Value<bool>? senderElevator,
      Value<bool>? buyerElevator,
      Value<String>? paymentTypeName,
      Value<String>? sellerName,
      Value<bool>? documentsReturn,
      Value<String>? deliveryAddressName,
      Value<String>? pickupAddressName,
      Value<int>? packages,
      Value<bool>? cardPaymentAllowed,
      Value<bool>? needPayment,
      Value<bool>? factsConfirmed,
      Value<int?>? storageId,
      Value<int>? deliveryLoadDuration,
      Value<int>? pickupLoadDuration,
      Value<String?>? productArrivalName,
      Value<String?>? productArrivalQR}) {
    return OrdersCompanion(
      id: id ?? this.id,
      deliveryDateTimeFrom: deliveryDateTimeFrom ?? this.deliveryDateTimeFrom,
      deliveryDateTimeTo: deliveryDateTimeTo ?? this.deliveryDateTimeTo,
      pickupDateTimeFrom: pickupDateTimeFrom ?? this.pickupDateTimeFrom,
      pickupDateTimeTo: pickupDateTimeTo ?? this.pickupDateTimeTo,
      number: number ?? this.number,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      senderName: senderName ?? this.senderName,
      buyerName: buyerName ?? this.buyerName,
      senderPhone: senderPhone ?? this.senderPhone,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      comment: comment ?? this.comment,
      deliveryTypeName: deliveryTypeName ?? this.deliveryTypeName,
      pickupTypeName: pickupTypeName ?? this.pickupTypeName,
      senderFloor: senderFloor ?? this.senderFloor,
      buyerFloor: buyerFloor ?? this.buyerFloor,
      senderFlat: senderFlat ?? this.senderFlat,
      buyerFlat: buyerFlat ?? this.buyerFlat,
      senderElevator: senderElevator ?? this.senderElevator,
      buyerElevator: buyerElevator ?? this.buyerElevator,
      paymentTypeName: paymentTypeName ?? this.paymentTypeName,
      sellerName: sellerName ?? this.sellerName,
      documentsReturn: documentsReturn ?? this.documentsReturn,
      deliveryAddressName: deliveryAddressName ?? this.deliveryAddressName,
      pickupAddressName: pickupAddressName ?? this.pickupAddressName,
      packages: packages ?? this.packages,
      cardPaymentAllowed: cardPaymentAllowed ?? this.cardPaymentAllowed,
      needPayment: needPayment ?? this.needPayment,
      factsConfirmed: factsConfirmed ?? this.factsConfirmed,
      storageId: storageId ?? this.storageId,
      deliveryLoadDuration: deliveryLoadDuration ?? this.deliveryLoadDuration,
      pickupLoadDuration: pickupLoadDuration ?? this.pickupLoadDuration,
      productArrivalName: productArrivalName ?? this.productArrivalName,
      productArrivalQR: productArrivalQR ?? this.productArrivalQR,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deliveryDateTimeFrom.present) {
      map['delivery_date_time_from'] =
          Variable<DateTime>(deliveryDateTimeFrom.value);
    }
    if (deliveryDateTimeTo.present) {
      map['delivery_date_time_to'] =
          Variable<DateTime>(deliveryDateTimeTo.value);
    }
    if (pickupDateTimeFrom.present) {
      map['pickup_date_time_from'] =
          Variable<DateTime>(pickupDateTimeFrom.value);
    }
    if (pickupDateTimeTo.present) {
      map['pickup_date_time_to'] = Variable<DateTime>(pickupDateTimeTo.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (trackingNumber.present) {
      map['tracking_number'] = Variable<String>(trackingNumber.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (buyerName.present) {
      map['buyer_name'] = Variable<String>(buyerName.value);
    }
    if (senderPhone.present) {
      map['sender_phone'] = Variable<String>(senderPhone.value);
    }
    if (buyerPhone.present) {
      map['buyer_phone'] = Variable<String>(buyerPhone.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (deliveryTypeName.present) {
      map['delivery_type_name'] = Variable<String>(deliveryTypeName.value);
    }
    if (pickupTypeName.present) {
      map['pickup_type_name'] = Variable<String>(pickupTypeName.value);
    }
    if (senderFloor.present) {
      map['sender_floor'] = Variable<int>(senderFloor.value);
    }
    if (buyerFloor.present) {
      map['buyer_floor'] = Variable<int>(buyerFloor.value);
    }
    if (senderFlat.present) {
      map['sender_flat'] = Variable<String>(senderFlat.value);
    }
    if (buyerFlat.present) {
      map['buyer_flat'] = Variable<String>(buyerFlat.value);
    }
    if (senderElevator.present) {
      map['sender_elevator'] = Variable<bool>(senderElevator.value);
    }
    if (buyerElevator.present) {
      map['buyer_elevator'] = Variable<bool>(buyerElevator.value);
    }
    if (paymentTypeName.present) {
      map['payment_type_name'] = Variable<String>(paymentTypeName.value);
    }
    if (sellerName.present) {
      map['seller_name'] = Variable<String>(sellerName.value);
    }
    if (documentsReturn.present) {
      map['documents_return'] = Variable<bool>(documentsReturn.value);
    }
    if (deliveryAddressName.present) {
      map['delivery_address_name'] =
          Variable<String>(deliveryAddressName.value);
    }
    if (pickupAddressName.present) {
      map['pickup_address_name'] = Variable<String>(pickupAddressName.value);
    }
    if (packages.present) {
      map['packages'] = Variable<int>(packages.value);
    }
    if (cardPaymentAllowed.present) {
      map['card_payment_allowed'] = Variable<bool>(cardPaymentAllowed.value);
    }
    if (needPayment.present) {
      map['need_payment'] = Variable<bool>(needPayment.value);
    }
    if (factsConfirmed.present) {
      map['facts_confirmed'] = Variable<bool>(factsConfirmed.value);
    }
    if (storageId.present) {
      map['storage_id'] = Variable<int>(storageId.value);
    }
    if (deliveryLoadDuration.present) {
      map['delivery_load_duration'] = Variable<int>(deliveryLoadDuration.value);
    }
    if (pickupLoadDuration.present) {
      map['pickup_load_duration'] = Variable<int>(pickupLoadDuration.value);
    }
    if (productArrivalName.present) {
      map['product_arrival_name'] = Variable<String>(productArrivalName.value);
    }
    if (productArrivalQR.present) {
      map['product_arrival_q_r'] = Variable<String>(productArrivalQR.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('deliveryDateTimeFrom: $deliveryDateTimeFrom, ')
          ..write('deliveryDateTimeTo: $deliveryDateTimeTo, ')
          ..write('pickupDateTimeFrom: $pickupDateTimeFrom, ')
          ..write('pickupDateTimeTo: $pickupDateTimeTo, ')
          ..write('number: $number, ')
          ..write('trackingNumber: $trackingNumber, ')
          ..write('senderName: $senderName, ')
          ..write('buyerName: $buyerName, ')
          ..write('senderPhone: $senderPhone, ')
          ..write('buyerPhone: $buyerPhone, ')
          ..write('comment: $comment, ')
          ..write('deliveryTypeName: $deliveryTypeName, ')
          ..write('pickupTypeName: $pickupTypeName, ')
          ..write('senderFloor: $senderFloor, ')
          ..write('buyerFloor: $buyerFloor, ')
          ..write('senderFlat: $senderFlat, ')
          ..write('buyerFlat: $buyerFlat, ')
          ..write('senderElevator: $senderElevator, ')
          ..write('buyerElevator: $buyerElevator, ')
          ..write('paymentTypeName: $paymentTypeName, ')
          ..write('sellerName: $sellerName, ')
          ..write('documentsReturn: $documentsReturn, ')
          ..write('deliveryAddressName: $deliveryAddressName, ')
          ..write('pickupAddressName: $pickupAddressName, ')
          ..write('packages: $packages, ')
          ..write('cardPaymentAllowed: $cardPaymentAllowed, ')
          ..write('needPayment: $needPayment, ')
          ..write('factsConfirmed: $factsConfirmed, ')
          ..write('storageId: $storageId, ')
          ..write('deliveryLoadDuration: $deliveryLoadDuration, ')
          ..write('pickupLoadDuration: $pickupLoadDuration, ')
          ..write('productArrivalName: $productArrivalName, ')
          ..write('productArrivalQR: $productArrivalQR')
          ..write(')'))
        .toString();
  }
}

class $DeliveryPointOrdersTable extends DeliveryPointOrders
    with TableInfo<$DeliveryPointOrdersTable, DeliveryPointOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryPointOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deliveryPointIdMeta =
      const VerificationMeta('deliveryPointId');
  @override
  late final GeneratedColumn<int> deliveryPointId = GeneratedColumn<int>(
      'delivery_point_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES delivery_points (id)'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (id)'));
  static const VerificationMeta _canceledMeta =
      const VerificationMeta('canceled');
  @override
  late final GeneratedColumn<bool> canceled = GeneratedColumn<bool>(
      'canceled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("canceled" IN (0, 1))'));
  static const VerificationMeta _finishedMeta =
      const VerificationMeta('finished');
  @override
  late final GeneratedColumn<bool> finished = GeneratedColumn<bool>(
      'finished', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("finished" IN (0, 1))'));
  static const VerificationMeta _pickupMeta = const VerificationMeta('pickup');
  @override
  late final GeneratedColumn<bool> pickup = GeneratedColumn<bool>(
      'pickup', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("pickup" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, deliveryPointId, orderId, canceled, finished, pickup];
  @override
  String get aliasedName => _alias ?? 'delivery_point_orders';
  @override
  String get actualTableName => 'delivery_point_orders';
  @override
  VerificationContext validateIntegrity(Insertable<DeliveryPointOrder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delivery_point_id')) {
      context.handle(
          _deliveryPointIdMeta,
          deliveryPointId.isAcceptableOrUnknown(
              data['delivery_point_id']!, _deliveryPointIdMeta));
    } else if (isInserting) {
      context.missing(_deliveryPointIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('canceled')) {
      context.handle(_canceledMeta,
          canceled.isAcceptableOrUnknown(data['canceled']!, _canceledMeta));
    } else if (isInserting) {
      context.missing(_canceledMeta);
    }
    if (data.containsKey('finished')) {
      context.handle(_finishedMeta,
          finished.isAcceptableOrUnknown(data['finished']!, _finishedMeta));
    } else if (isInserting) {
      context.missing(_finishedMeta);
    }
    if (data.containsKey('pickup')) {
      context.handle(_pickupMeta,
          pickup.isAcceptableOrUnknown(data['pickup']!, _pickupMeta));
    } else if (isInserting) {
      context.missing(_pickupMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveryPointOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryPointOrder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deliveryPointId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}delivery_point_id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      canceled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}canceled'])!,
      finished: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}finished'])!,
      pickup: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pickup'])!,
    );
  }

  @override
  $DeliveryPointOrdersTable createAlias(String alias) {
    return $DeliveryPointOrdersTable(attachedDatabase, alias);
  }
}

class DeliveryPointOrder extends DataClass
    implements Insertable<DeliveryPointOrder> {
  final int id;
  final int deliveryPointId;
  final int orderId;
  final bool canceled;
  final bool finished;
  final bool pickup;
  const DeliveryPointOrder(
      {required this.id,
      required this.deliveryPointId,
      required this.orderId,
      required this.canceled,
      required this.finished,
      required this.pickup});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['delivery_point_id'] = Variable<int>(deliveryPointId);
    map['order_id'] = Variable<int>(orderId);
    map['canceled'] = Variable<bool>(canceled);
    map['finished'] = Variable<bool>(finished);
    map['pickup'] = Variable<bool>(pickup);
    return map;
  }

  DeliveryPointOrdersCompanion toCompanion(bool nullToAbsent) {
    return DeliveryPointOrdersCompanion(
      id: Value(id),
      deliveryPointId: Value(deliveryPointId),
      orderId: Value(orderId),
      canceled: Value(canceled),
      finished: Value(finished),
      pickup: Value(pickup),
    );
  }

  factory DeliveryPointOrder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryPointOrder(
      id: serializer.fromJson<int>(json['id']),
      deliveryPointId: serializer.fromJson<int>(json['deliveryPointId']),
      orderId: serializer.fromJson<int>(json['orderId']),
      canceled: serializer.fromJson<bool>(json['canceled']),
      finished: serializer.fromJson<bool>(json['finished']),
      pickup: serializer.fromJson<bool>(json['pickup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deliveryPointId': serializer.toJson<int>(deliveryPointId),
      'orderId': serializer.toJson<int>(orderId),
      'canceled': serializer.toJson<bool>(canceled),
      'finished': serializer.toJson<bool>(finished),
      'pickup': serializer.toJson<bool>(pickup),
    };
  }

  DeliveryPointOrder copyWith(
          {int? id,
          int? deliveryPointId,
          int? orderId,
          bool? canceled,
          bool? finished,
          bool? pickup}) =>
      DeliveryPointOrder(
        id: id ?? this.id,
        deliveryPointId: deliveryPointId ?? this.deliveryPointId,
        orderId: orderId ?? this.orderId,
        canceled: canceled ?? this.canceled,
        finished: finished ?? this.finished,
        pickup: pickup ?? this.pickup,
      );
  @override
  String toString() {
    return (StringBuffer('DeliveryPointOrder(')
          ..write('id: $id, ')
          ..write('deliveryPointId: $deliveryPointId, ')
          ..write('orderId: $orderId, ')
          ..write('canceled: $canceled, ')
          ..write('finished: $finished, ')
          ..write('pickup: $pickup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deliveryPointId, orderId, canceled, finished, pickup);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryPointOrder &&
          other.id == this.id &&
          other.deliveryPointId == this.deliveryPointId &&
          other.orderId == this.orderId &&
          other.canceled == this.canceled &&
          other.finished == this.finished &&
          other.pickup == this.pickup);
}

class DeliveryPointOrdersCompanion extends UpdateCompanion<DeliveryPointOrder> {
  final Value<int> id;
  final Value<int> deliveryPointId;
  final Value<int> orderId;
  final Value<bool> canceled;
  final Value<bool> finished;
  final Value<bool> pickup;
  const DeliveryPointOrdersCompanion({
    this.id = const Value.absent(),
    this.deliveryPointId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.canceled = const Value.absent(),
    this.finished = const Value.absent(),
    this.pickup = const Value.absent(),
  });
  DeliveryPointOrdersCompanion.insert({
    this.id = const Value.absent(),
    required int deliveryPointId,
    required int orderId,
    required bool canceled,
    required bool finished,
    required bool pickup,
  })  : deliveryPointId = Value(deliveryPointId),
        orderId = Value(orderId),
        canceled = Value(canceled),
        finished = Value(finished),
        pickup = Value(pickup);
  static Insertable<DeliveryPointOrder> custom({
    Expression<int>? id,
    Expression<int>? deliveryPointId,
    Expression<int>? orderId,
    Expression<bool>? canceled,
    Expression<bool>? finished,
    Expression<bool>? pickup,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deliveryPointId != null) 'delivery_point_id': deliveryPointId,
      if (orderId != null) 'order_id': orderId,
      if (canceled != null) 'canceled': canceled,
      if (finished != null) 'finished': finished,
      if (pickup != null) 'pickup': pickup,
    });
  }

  DeliveryPointOrdersCompanion copyWith(
      {Value<int>? id,
      Value<int>? deliveryPointId,
      Value<int>? orderId,
      Value<bool>? canceled,
      Value<bool>? finished,
      Value<bool>? pickup}) {
    return DeliveryPointOrdersCompanion(
      id: id ?? this.id,
      deliveryPointId: deliveryPointId ?? this.deliveryPointId,
      orderId: orderId ?? this.orderId,
      canceled: canceled ?? this.canceled,
      finished: finished ?? this.finished,
      pickup: pickup ?? this.pickup,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deliveryPointId.present) {
      map['delivery_point_id'] = Variable<int>(deliveryPointId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (canceled.present) {
      map['canceled'] = Variable<bool>(canceled.value);
    }
    if (finished.present) {
      map['finished'] = Variable<bool>(finished.value);
    }
    if (pickup.present) {
      map['pickup'] = Variable<bool>(pickup.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryPointOrdersCompanion(')
          ..write('id: $id, ')
          ..write('deliveryPointId: $deliveryPointId, ')
          ..write('orderId: $orderId, ')
          ..write('canceled: $canceled, ')
          ..write('finished: $finished, ')
          ..write('pickup: $pickup')
          ..write(')'))
        .toString();
  }
}

class $OrderLinesTable extends OrderLines
    with TableInfo<$OrderLinesTable, OrderLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
      'amount', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _factAmountMeta =
      const VerificationMeta('factAmount');
  @override
  late final GeneratedColumn<int> factAmount = GeneratedColumn<int>(
      'fact_amount', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, name, amount, price, factAmount];
  @override
  String get aliasedName => _alias ?? 'order_lines';
  @override
  String get actualTableName => 'order_lines';
  @override
  VerificationContext validateIntegrity(Insertable<OrderLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('fact_amount')) {
      context.handle(
          _factAmountMeta,
          factAmount.isAcceptableOrUnknown(
              data['fact_amount']!, _factAmountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      factAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}fact_amount']),
    );
  }

  @override
  $OrderLinesTable createAlias(String alias) {
    return $OrderLinesTable(attachedDatabase, alias);
  }
}

class OrderLine extends DataClass implements Insertable<OrderLine> {
  final int id;
  final int orderId;
  final String name;
  final int amount;
  final double price;
  final int? factAmount;
  const OrderLine(
      {required this.id,
      required this.orderId,
      required this.name,
      required this.amount,
      required this.price,
      this.factAmount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<int>(amount);
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || factAmount != null) {
      map['fact_amount'] = Variable<int>(factAmount);
    }
    return map;
  }

  OrderLinesCompanion toCompanion(bool nullToAbsent) {
    return OrderLinesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      name: Value(name),
      amount: Value(amount),
      price: Value(price),
      factAmount: factAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(factAmount),
    );
  }

  factory OrderLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderLine(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<int>(json['amount']),
      price: serializer.fromJson<double>(json['price']),
      factAmount: serializer.fromJson<int?>(json['factAmount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<int>(amount),
      'price': serializer.toJson<double>(price),
      'factAmount': serializer.toJson<int?>(factAmount),
    };
  }

  OrderLine copyWith(
          {int? id,
          int? orderId,
          String? name,
          int? amount,
          double? price,
          Value<int?> factAmount = const Value.absent()}) =>
      OrderLine(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        price: price ?? this.price,
        factAmount: factAmount.present ? factAmount.value : this.factAmount,
      );
  @override
  String toString() {
    return (StringBuffer('OrderLine(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('price: $price, ')
          ..write('factAmount: $factAmount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, name, amount, price, factAmount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderLine &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.price == this.price &&
          other.factAmount == this.factAmount);
}

class OrderLinesCompanion extends UpdateCompanion<OrderLine> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<String> name;
  final Value<int> amount;
  final Value<double> price;
  final Value<int?> factAmount;
  const OrderLinesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.price = const Value.absent(),
    this.factAmount = const Value.absent(),
  });
  OrderLinesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required String name,
    required int amount,
    required double price,
    this.factAmount = const Value.absent(),
  })  : orderId = Value(orderId),
        name = Value(name),
        amount = Value(amount),
        price = Value(price);
  static Insertable<OrderLine> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<String>? name,
    Expression<int>? amount,
    Expression<double>? price,
    Expression<int>? factAmount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (price != null) 'price': price,
      if (factAmount != null) 'fact_amount': factAmount,
    });
  }

  OrderLinesCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<String>? name,
      Value<int>? amount,
      Value<double>? price,
      Value<int?>? factAmount}) {
    return OrderLinesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      factAmount: factAmount ?? this.factAmount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (factAmount.present) {
      map['fact_amount'] = Variable<int>(factAmount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderLinesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('price: $price, ')
          ..write('factAmount: $factAmount')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deliveryPointOrderIdMeta =
      const VerificationMeta('deliveryPointOrderId');
  @override
  late final GeneratedColumn<int> deliveryPointOrderId = GeneratedColumn<int>(
      'delivery_point_order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES delivery_point_orders (id)'));
  static const VerificationMeta _summMeta = const VerificationMeta('summ');
  @override
  late final GeneratedColumn<double> summ = GeneratedColumn<double>(
      'summ', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _transactionIdMeta =
      const VerificationMeta('transactionId');
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
      'transaction_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, deliveryPointOrderId, summ, transactionId];
  @override
  String get aliasedName => _alias ?? 'payments';
  @override
  String get actualTableName => 'payments';
  @override
  VerificationContext validateIntegrity(Insertable<Payment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('delivery_point_order_id')) {
      context.handle(
          _deliveryPointOrderIdMeta,
          deliveryPointOrderId.isAcceptableOrUnknown(
              data['delivery_point_order_id']!, _deliveryPointOrderIdMeta));
    } else if (isInserting) {
      context.missing(_deliveryPointOrderIdMeta);
    }
    if (data.containsKey('summ')) {
      context.handle(
          _summMeta, summ.isAcceptableOrUnknown(data['summ']!, _summMeta));
    } else if (isInserting) {
      context.missing(_summMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
          _transactionIdMeta,
          transactionId.isAcceptableOrUnknown(
              data['transaction_id']!, _transactionIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deliveryPointOrderId: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}delivery_point_order_id'])!,
      summ: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}summ'])!,
      transactionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transaction_id']),
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final int id;
  final int deliveryPointOrderId;
  final double summ;
  final String? transactionId;
  const Payment(
      {required this.id,
      required this.deliveryPointOrderId,
      required this.summ,
      this.transactionId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['delivery_point_order_id'] = Variable<int>(deliveryPointOrderId);
    map['summ'] = Variable<double>(summ);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      deliveryPointOrderId: Value(deliveryPointOrderId),
      summ: Value(summ),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<int>(json['id']),
      deliveryPointOrderId:
          serializer.fromJson<int>(json['deliveryPointOrderId']),
      summ: serializer.fromJson<double>(json['summ']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deliveryPointOrderId': serializer.toJson<int>(deliveryPointOrderId),
      'summ': serializer.toJson<double>(summ),
      'transactionId': serializer.toJson<String?>(transactionId),
    };
  }

  Payment copyWith(
          {int? id,
          int? deliveryPointOrderId,
          double? summ,
          Value<String?> transactionId = const Value.absent()}) =>
      Payment(
        id: id ?? this.id,
        deliveryPointOrderId: deliveryPointOrderId ?? this.deliveryPointOrderId,
        summ: summ ?? this.summ,
        transactionId:
            transactionId.present ? transactionId.value : this.transactionId,
      );
  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('deliveryPointOrderId: $deliveryPointOrderId, ')
          ..write('summ: $summ, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deliveryPointOrderId, summ, transactionId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.deliveryPointOrderId == this.deliveryPointOrderId &&
          other.summ == this.summ &&
          other.transactionId == this.transactionId);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<int> id;
  final Value<int> deliveryPointOrderId;
  final Value<double> summ;
  final Value<String?> transactionId;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.deliveryPointOrderId = const Value.absent(),
    this.summ = const Value.absent(),
    this.transactionId = const Value.absent(),
  });
  PaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int deliveryPointOrderId,
    required double summ,
    this.transactionId = const Value.absent(),
  })  : deliveryPointOrderId = Value(deliveryPointOrderId),
        summ = Value(summ);
  static Insertable<Payment> custom({
    Expression<int>? id,
    Expression<int>? deliveryPointOrderId,
    Expression<double>? summ,
    Expression<String>? transactionId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deliveryPointOrderId != null)
        'delivery_point_order_id': deliveryPointOrderId,
      if (summ != null) 'summ': summ,
      if (transactionId != null) 'transaction_id': transactionId,
    });
  }

  PaymentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? deliveryPointOrderId,
      Value<double>? summ,
      Value<String?>? transactionId}) {
    return PaymentsCompanion(
      id: id ?? this.id,
      deliveryPointOrderId: deliveryPointOrderId ?? this.deliveryPointOrderId,
      summ: summ ?? this.summ,
      transactionId: transactionId ?? this.transactionId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deliveryPointOrderId.present) {
      map['delivery_point_order_id'] =
          Variable<int>(deliveryPointOrderId.value);
    }
    if (summ.present) {
      map['summ'] = Variable<double>(summ.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('deliveryPointOrderId: $deliveryPointOrderId, ')
          ..write('summ: $summ, ')
          ..write('transactionId: $transactionId')
          ..write(')'))
        .toString();
  }
}

class $OrderInfoLinesTable extends OrderInfoLines
    with TableInfo<$OrderInfoLinesTable, OrderInfoLine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderInfoLinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES orders (id)'));
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tsMeta = const VerificationMeta('ts');
  @override
  late final GeneratedColumn<DateTime> ts = GeneratedColumn<DateTime>(
      'ts', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, orderId, comment, ts];
  @override
  String get aliasedName => _alias ?? 'order_info_lines';
  @override
  String get actualTableName => 'order_info_lines';
  @override
  VerificationContext validateIntegrity(Insertable<OrderInfoLine> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    } else if (isInserting) {
      context.missing(_commentMeta);
    }
    if (data.containsKey('ts')) {
      context.handle(_tsMeta, ts.isAcceptableOrUnknown(data['ts']!, _tsMeta));
    } else if (isInserting) {
      context.missing(_tsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderInfoLine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderInfoLine(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment'])!,
      ts: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ts'])!,
    );
  }

  @override
  $OrderInfoLinesTable createAlias(String alias) {
    return $OrderInfoLinesTable(attachedDatabase, alias);
  }
}

class OrderInfoLine extends DataClass implements Insertable<OrderInfoLine> {
  final int id;
  final int orderId;
  final String comment;
  final DateTime ts;
  const OrderInfoLine(
      {required this.id,
      required this.orderId,
      required this.comment,
      required this.ts});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['comment'] = Variable<String>(comment);
    map['ts'] = Variable<DateTime>(ts);
    return map;
  }

  OrderInfoLinesCompanion toCompanion(bool nullToAbsent) {
    return OrderInfoLinesCompanion(
      id: Value(id),
      orderId: Value(orderId),
      comment: Value(comment),
      ts: Value(ts),
    );
  }

  factory OrderInfoLine.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderInfoLine(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      comment: serializer.fromJson<String>(json['comment']),
      ts: serializer.fromJson<DateTime>(json['ts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'comment': serializer.toJson<String>(comment),
      'ts': serializer.toJson<DateTime>(ts),
    };
  }

  OrderInfoLine copyWith(
          {int? id, int? orderId, String? comment, DateTime? ts}) =>
      OrderInfoLine(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        comment: comment ?? this.comment,
        ts: ts ?? this.ts,
      );
  @override
  String toString() {
    return (StringBuffer('OrderInfoLine(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('comment: $comment, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, comment, ts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderInfoLine &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.comment == this.comment &&
          other.ts == this.ts);
}

class OrderInfoLinesCompanion extends UpdateCompanion<OrderInfoLine> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<String> comment;
  final Value<DateTime> ts;
  const OrderInfoLinesCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.comment = const Value.absent(),
    this.ts = const Value.absent(),
  });
  OrderInfoLinesCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required String comment,
    required DateTime ts,
  })  : orderId = Value(orderId),
        comment = Value(comment),
        ts = Value(ts);
  static Insertable<OrderInfoLine> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<String>? comment,
    Expression<DateTime>? ts,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (comment != null) 'comment': comment,
      if (ts != null) 'ts': ts,
    });
  }

  OrderInfoLinesCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<String>? comment,
      Value<DateTime>? ts}) {
    return OrderInfoLinesCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      comment: comment ?? this.comment,
      ts: ts ?? this.ts,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (ts.present) {
      map['ts'] = Variable<DateTime>(ts.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderInfoLinesCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('comment: $comment, ')
          ..write('ts: $ts')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _storageIdMeta =
      const VerificationMeta('storageId');
  @override
  late final GeneratedColumn<int> storageId = GeneratedColumn<int>(
      'storage_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES order_storages (id)'));
  static const VerificationMeta _storageQRMeta =
      const VerificationMeta('storageQR');
  @override
  late final GeneratedColumn<String> storageQR = GeneratedColumn<String>(
      'storage_q_r', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
      'version', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, username, name, email, storageId, storageQR, version];
  @override
  String get aliasedName => _alias ?? 'users';
  @override
  String get actualTableName => 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('storage_id')) {
      context.handle(_storageIdMeta,
          storageId.isAcceptableOrUnknown(data['storage_id']!, _storageIdMeta));
    } else if (isInserting) {
      context.missing(_storageIdMeta);
    }
    if (data.containsKey('storage_q_r')) {
      context.handle(
          _storageQRMeta,
          storageQR.isAcceptableOrUnknown(
              data['storage_q_r']!, _storageQRMeta));
    } else if (isInserting) {
      context.missing(_storageQRMeta);
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      storageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}storage_id'])!,
      storageQR: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}storage_q_r'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}version'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String username;
  final String name;
  final String email;
  final int storageId;
  final String storageQR;
  final String version;
  const User(
      {required this.id,
      required this.username,
      required this.name,
      required this.email,
      required this.storageId,
      required this.storageQR,
      required this.version});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['storage_id'] = Variable<int>(storageId);
    map['storage_q_r'] = Variable<String>(storageQR);
    map['version'] = Variable<String>(version);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      name: Value(name),
      email: Value(email),
      storageId: Value(storageId),
      storageQR: Value(storageQR),
      version: Value(version),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      storageId: serializer.fromJson<int>(json['storageId']),
      storageQR: serializer.fromJson<String>(json['storageQR']),
      version: serializer.fromJson<String>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'storageId': serializer.toJson<int>(storageId),
      'storageQR': serializer.toJson<String>(storageQR),
      'version': serializer.toJson<String>(version),
    };
  }

  User copyWith(
          {int? id,
          String? username,
          String? name,
          String? email,
          int? storageId,
          String? storageQR,
          String? version}) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        name: name ?? this.name,
        email: email ?? this.email,
        storageId: storageId ?? this.storageId,
        storageQR: storageQR ?? this.storageQR,
        version: version ?? this.version,
      );
  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('storageId: $storageId, ')
          ..write('storageQR: $storageQR, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, username, name, email, storageId, storageQR, version);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.name == this.name &&
          other.email == this.email &&
          other.storageId == this.storageId &&
          other.storageQR == this.storageQR &&
          other.version == this.version);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> name;
  final Value<String> email;
  final Value<int> storageId;
  final Value<String> storageQR;
  final Value<String> version;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.storageId = const Value.absent(),
    this.storageQR = const Value.absent(),
    this.version = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String name,
    required String email,
    required int storageId,
    required String storageQR,
    required String version,
  })  : username = Value(username),
        name = Value(name),
        email = Value(email),
        storageId = Value(storageId),
        storageQR = Value(storageQR),
        version = Value(version);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? name,
    Expression<String>? email,
    Expression<int>? storageId,
    Expression<String>? storageQR,
    Expression<String>? version,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (storageId != null) 'storage_id': storageId,
      if (storageQR != null) 'storage_q_r': storageQR,
      if (version != null) 'version': version,
    });
  }

  UsersCompanion copyWith(
      {Value<int>? id,
      Value<String>? username,
      Value<String>? name,
      Value<String>? email,
      Value<int>? storageId,
      Value<String>? storageQR,
      Value<String>? version}) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      storageId: storageId ?? this.storageId,
      storageQR: storageQR ?? this.storageQR,
      version: version ?? this.version,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (storageId.present) {
      map['storage_id'] = Variable<int>(storageId.value);
    }
    if (storageQR.present) {
      map['storage_q_r'] = Variable<String>(storageQR.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('storageId: $storageId, ')
          ..write('storageQR: $storageQR, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _lastSyncMeta =
      const VerificationMeta('lastSync');
  @override
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
      'last_sync', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, lastSync];
  @override
  String get aliasedName => _alias ?? 'settings';
  @override
  String get actualTableName => 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_sync')) {
      context.handle(_lastSyncMeta,
          lastSync.isAcceptableOrUnknown(data['last_sync']!, _lastSyncMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lastSync: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync']),
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final DateTime? lastSync;
  const Setting({required this.id, this.lastSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || lastSync != null) {
      map['last_sync'] = Variable<DateTime>(lastSync);
    }
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      lastSync: lastSync == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSync),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      lastSync: serializer.fromJson<DateTime?>(json['lastSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastSync': serializer.toJson<DateTime?>(lastSync),
    };
  }

  Setting copyWith(
          {int? id, Value<DateTime?> lastSync = const Value.absent()}) =>
      Setting(
        id: id ?? this.id,
        lastSync: lastSync.present ? lastSync.value : this.lastSync,
      );
  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, lastSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.lastSync == this.lastSync);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<DateTime?> lastSync;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.lastSync = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    this.lastSync = const Value.absent(),
  });
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<DateTime>? lastSync,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastSync != null) 'last_sync': lastSync,
    });
  }

  SettingsCompanion copyWith({Value<int>? id, Value<DateTime?>? lastSync}) {
    return SettingsCompanion(
      id: id ?? this.id,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppStorage extends GeneratedDatabase {
  _$AppStorage(QueryExecutor e) : super(e);
  late final $DeliveriesTable deliveries = $DeliveriesTable(this);
  late final $DeliveryPointsTable deliveryPoints = $DeliveryPointsTable(this);
  late final $OrderStoragesTable orderStorages = $OrderStoragesTable(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $DeliveryPointOrdersTable deliveryPointOrders =
      $DeliveryPointOrdersTable(this);
  late final $OrderLinesTable orderLines = $OrderLinesTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $OrderInfoLinesTable orderInfoLines = $OrderInfoLinesTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final DeliveriesDao deliveriesDao = DeliveriesDao(this as AppStorage);
  late final OrderStoragesDao orderStoragesDao =
      OrderStoragesDao(this as AppStorage);
  late final OrdersDao ordersDao = OrdersDao(this as AppStorage);
  late final PaymentsDao paymentsDao = PaymentsDao(this as AppStorage);
  late final UsersDao usersDao = UsersDao(this as AppStorage);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        deliveries,
        deliveryPoints,
        orderStorages,
        orders,
        deliveryPointOrders,
        orderLines,
        payments,
        orderInfoLines,
        users,
        settings
      ];
}

mixin _$DeliveriesDaoMixin on DatabaseAccessor<AppStorage> {
  $DeliveriesTable get deliveries => attachedDatabase.deliveries;
  $DeliveryPointsTable get deliveryPoints => attachedDatabase.deliveryPoints;
  $OrderStoragesTable get orderStorages => attachedDatabase.orderStorages;
  $OrdersTable get orders => attachedDatabase.orders;
  $DeliveryPointOrdersTable get deliveryPointOrders =>
      attachedDatabase.deliveryPointOrders;
  Selectable<DeliveryPointExResult> deliveryPointEx() {
    return customSelect(
        'SELECT"dp"."id" AS "nested_0.id", "dp"."delivery_id" AS "nested_0.delivery_id", "dp"."seq" AS "nested_0.seq", "dp"."plan_arrival" AS "nested_0.plan_arrival", "dp"."plan_departure" AS "nested_0.plan_departure", "dp"."fact_arrival" AS "nested_0.fact_arrival", "dp"."fact_departure" AS "nested_0.fact_departure", "dp"."address_name" AS "nested_0.address_name", "dp"."latitude" AS "nested_0.latitude", "dp"."longitude" AS "nested_0.longitude", "dp"."seller_name" AS "nested_0.seller_name", "dp"."buyer_name" AS "nested_0.buyer_name", "dp"."phone" AS "nested_0.phone", "dp"."payment_type_name" AS "nested_0.payment_type_name", "dp"."delivery_type_name" AS "nested_0.delivery_type_name", "dp"."pickup_seller_name" AS "nested_0.pickup_seller_name", "dp"."sender_name" AS "nested_0.sender_name", "dp"."sender_phone" AS "nested_0.sender_phone", CAST(CASE WHEN dp.fact_arrival IS NULL THEN 1 ELSE 0 END AS INT) AS is_not_arrived, CAST(NOT EXISTS (SELECT 1 AS _c0 FROM delivery_point_orders AS dpo JOIN orders AS o ON o.id = dpo.order_id WHERE dpo.delivery_point_id = dp.id AND dpo.finished = 0) AS INT) AS is_finished, CAST(CASE WHEN(CASE WHEN dp.fact_arrival IS NULL THEN 1 ELSE 0 END = 1)AND NOT EXISTS (SELECT 1 AS _c1 FROM delivery_point_orders AS dpo JOIN orders AS o ON o.id = dpo.order_id WHERE dpo.delivery_point_id = dp.id AND dpo.finished = 0) THEN 1 WHEN(CASE WHEN dp.fact_arrival IS NULL THEN 1 ELSE 0 END = 0)AND NOT EXISTS (SELECT 1 AS _c2 FROM delivery_point_orders AS dpo JOIN orders AS o ON o.id = dpo.order_id WHERE dpo.delivery_point_id = dp.id AND dpo.finished = 0) THEN NOT EXISTS (SELECT 1 AS _c3 FROM delivery_point_orders AS dpo JOIN orders AS o ON o.id = dpo.order_id WHERE dpo.pickup = 0 AND dpo.delivery_point_id = dp.id AND o.need_payment = 1) ELSE 0 END AS INT) AS is_completed, (SELECT MAX(CASE dpo.pickup WHEN 1 THEN o.pickup_date_time_from ELSE o.delivery_date_time_from END) FROM delivery_point_orders AS dpo JOIN orders AS o ON o.id = dpo.order_id WHERE dpo.delivery_point_id = dp.id) AS date_time_from, (SELECT MAX(CASE dpo.pickup WHEN 1 THEN o.pickup_date_time_to ELSE o.delivery_date_time_to END) FROM delivery_point_orders AS dpo JOIN orders AS o ON o.id = dpo.order_id WHERE dpo.delivery_point_id = dp.id) AS date_time_to FROM deliveries AS d JOIN delivery_points AS dp ON dp.delivery_id = d.id ORDER BY d.delivery_date ASC, dp.seq ASC',
        variables: [],
        readsFrom: {
          deliveryPoints,
          deliveryPointOrders,
          orders,
          deliveries,
        }).asyncMap((QueryRow row) async => DeliveryPointExResult(
          dp: await deliveryPoints.mapFromRow(row, tablePrefix: 'nested_0'),
          isNotArrived: row.read<bool>('is_not_arrived'),
          isFinished: row.read<bool>('is_finished'),
          isCompleted: row.read<bool>('is_completed'),
          dateTimeFrom: row.readNullable<DateTime>('date_time_from'),
          dateTimeTo: row.readNullable<DateTime>('date_time_to'),
        ));
  }

  Selectable<DeliveryPointOrderExResult> deliveryPointOrderEx() {
    return customSelect(
        'SELECT"dpo"."id" AS "nested_0.id", "dpo"."delivery_point_id" AS "nested_0.delivery_point_id", "dpo"."order_id" AS "nested_0.order_id", "dpo"."canceled" AS "nested_0.canceled", "dpo"."finished" AS "nested_0.finished", "dpo"."pickup" AS "nested_0.pickup","o"."id" AS "nested_1.id", "o"."delivery_date_time_from" AS "nested_1.delivery_date_time_from", "o"."delivery_date_time_to" AS "nested_1.delivery_date_time_to", "o"."pickup_date_time_from" AS "nested_1.pickup_date_time_from", "o"."pickup_date_time_to" AS "nested_1.pickup_date_time_to", "o"."number" AS "nested_1.number", "o"."tracking_number" AS "nested_1.tracking_number", "o"."sender_name" AS "nested_1.sender_name", "o"."buyer_name" AS "nested_1.buyer_name", "o"."sender_phone" AS "nested_1.sender_phone", "o"."buyer_phone" AS "nested_1.buyer_phone", "o"."comment" AS "nested_1.comment", "o"."delivery_type_name" AS "nested_1.delivery_type_name", "o"."pickup_type_name" AS "nested_1.pickup_type_name", "o"."sender_floor" AS "nested_1.sender_floor", "o"."buyer_floor" AS "nested_1.buyer_floor", "o"."sender_flat" AS "nested_1.sender_flat", "o"."buyer_flat" AS "nested_1.buyer_flat", "o"."sender_elevator" AS "nested_1.sender_elevator", "o"."buyer_elevator" AS "nested_1.buyer_elevator", "o"."payment_type_name" AS "nested_1.payment_type_name", "o"."seller_name" AS "nested_1.seller_name", "o"."documents_return" AS "nested_1.documents_return", "o"."delivery_address_name" AS "nested_1.delivery_address_name", "o"."pickup_address_name" AS "nested_1.pickup_address_name", "o"."packages" AS "nested_1.packages", "o"."card_payment_allowed" AS "nested_1.card_payment_allowed", "o"."need_payment" AS "nested_1.need_payment", "o"."facts_confirmed" AS "nested_1.facts_confirmed", "o"."storage_id" AS "nested_1.storage_id", "o"."delivery_load_duration" AS "nested_1.delivery_load_duration", "o"."pickup_load_duration" AS "nested_1.pickup_load_duration", "o"."product_arrival_name" AS "nested_1.product_arrival_name", "o"."product_arrival_q_r" AS "nested_1.product_arrival_q_r" FROM delivery_point_orders AS dpo JOIN orders AS o ON o.id = dpo.order_id ORDER BY o.tracking_number ASC',
        variables: [],
        readsFrom: {
          deliveryPointOrders,
          orders,
        }).asyncMap((QueryRow row) async => DeliveryPointOrderExResult(
          dpo: await deliveryPointOrders.mapFromRow(row,
              tablePrefix: 'nested_0'),
          o: await orders.mapFromRow(row, tablePrefix: 'nested_1'),
        ));
  }
}

class DeliveryPointExResult {
  final DeliveryPoint dp;
  final bool isNotArrived;
  final bool isFinished;
  final bool isCompleted;
  final DateTime? dateTimeFrom;
  final DateTime? dateTimeTo;
  DeliveryPointExResult({
    required this.dp,
    required this.isNotArrived,
    required this.isFinished,
    required this.isCompleted,
    this.dateTimeFrom,
    this.dateTimeTo,
  });
}

class DeliveryPointOrderExResult {
  final DeliveryPointOrder dpo;
  final Order o;
  DeliveryPointOrderExResult({
    required this.dpo,
    required this.o,
  });
}

mixin _$OrderStoragesDaoMixin on DatabaseAccessor<AppStorage> {
  $OrderStoragesTable get orderStorages => attachedDatabase.orderStorages;
  $UsersTable get users => attachedDatabase.users;
}
mixin _$OrdersDaoMixin on DatabaseAccessor<AppStorage> {
  $OrderStoragesTable get orderStorages => attachedDatabase.orderStorages;
  $OrdersTable get orders => attachedDatabase.orders;
  $OrderLinesTable get orderLines => attachedDatabase.orderLines;
  $OrderInfoLinesTable get orderInfoLines => attachedDatabase.orderInfoLines;
  $UsersTable get users => attachedDatabase.users;
  $DeliveriesTable get deliveries => attachedDatabase.deliveries;
  $DeliveryPointsTable get deliveryPoints => attachedDatabase.deliveryPoints;
  $DeliveryPointOrdersTable get deliveryPointOrders =>
      attachedDatabase.deliveryPointOrders;
  Selectable<OrderWithTransferResult> orderWithTransfer() {
    return customSelect(
        'SELECT o.*, EXISTS (SELECT 1 AS _c0 FROM users WHERE users.storage_id = o.storage_id) AS own, EXISTS (SELECT 1 AS _c1 FROM delivery_point_orders AS dpo WHERE dpo.order_id = o.id AND dpo.pickup = 0 AND dpo.finished = 0) AS need_transfer FROM orders AS o LEFT JOIN order_storages AS os ON os.id = o.storage_id',
        variables: [],
        readsFrom: {
          users,
          orders,
          deliveryPointOrders,
          orderStorages,
        }).map((QueryRow row) => OrderWithTransferResult(
          id: row.read<int>('id'),
          deliveryDateTimeFrom:
              row.readNullable<DateTime>('delivery_date_time_from'),
          deliveryDateTimeTo:
              row.readNullable<DateTime>('delivery_date_time_to'),
          pickupDateTimeFrom:
              row.readNullable<DateTime>('pickup_date_time_from'),
          pickupDateTimeTo: row.readNullable<DateTime>('pickup_date_time_to'),
          number: row.read<String>('number'),
          trackingNumber: row.read<String>('tracking_number'),
          senderName: row.readNullable<String>('sender_name'),
          buyerName: row.readNullable<String>('buyer_name'),
          senderPhone: row.readNullable<String>('sender_phone'),
          buyerPhone: row.readNullable<String>('buyer_phone'),
          comment: row.readNullable<String>('comment'),
          deliveryTypeName: row.read<String>('delivery_type_name'),
          pickupTypeName: row.read<String>('pickup_type_name'),
          senderFloor: row.readNullable<int>('sender_floor'),
          buyerFloor: row.readNullable<int>('buyer_floor'),
          senderFlat: row.readNullable<String>('sender_flat'),
          buyerFlat: row.readNullable<String>('buyer_flat'),
          senderElevator: row.read<bool>('sender_elevator'),
          buyerElevator: row.read<bool>('buyer_elevator'),
          paymentTypeName: row.read<String>('payment_type_name'),
          sellerName: row.read<String>('seller_name'),
          documentsReturn: row.read<bool>('documents_return'),
          deliveryAddressName: row.read<String>('delivery_address_name'),
          pickupAddressName: row.read<String>('pickup_address_name'),
          packages: row.read<int>('packages'),
          cardPaymentAllowed: row.read<bool>('card_payment_allowed'),
          needPayment: row.read<bool>('need_payment'),
          factsConfirmed: row.read<bool>('facts_confirmed'),
          storageId: row.readNullable<int>('storage_id'),
          deliveryLoadDuration: row.read<int>('delivery_load_duration'),
          pickupLoadDuration: row.read<int>('pickup_load_duration'),
          productArrivalName: row.readNullable<String>('product_arrival_name'),
          productArrivalQR: row.readNullable<String>('product_arrival_q_r'),
          own: row.read<bool>('own'),
          needTransfer: row.read<bool>('need_transfer'),
        ));
  }
}

class OrderWithTransferResult {
  final int id;
  final DateTime? deliveryDateTimeFrom;
  final DateTime? deliveryDateTimeTo;
  final DateTime? pickupDateTimeFrom;
  final DateTime? pickupDateTimeTo;
  final String number;
  final String trackingNumber;
  final String? senderName;
  final String? buyerName;
  final String? senderPhone;
  final String? buyerPhone;
  final String? comment;
  final String deliveryTypeName;
  final String pickupTypeName;
  final int? senderFloor;
  final int? buyerFloor;
  final String? senderFlat;
  final String? buyerFlat;
  final bool senderElevator;
  final bool buyerElevator;
  final String paymentTypeName;
  final String sellerName;
  final bool documentsReturn;
  final String deliveryAddressName;
  final String pickupAddressName;
  final int packages;
  final bool cardPaymentAllowed;
  final bool needPayment;
  final bool factsConfirmed;
  final int? storageId;
  final int deliveryLoadDuration;
  final int pickupLoadDuration;
  final String? productArrivalName;
  final String? productArrivalQR;
  final bool own;
  final bool needTransfer;
  OrderWithTransferResult({
    required this.id,
    this.deliveryDateTimeFrom,
    this.deliveryDateTimeTo,
    this.pickupDateTimeFrom,
    this.pickupDateTimeTo,
    required this.number,
    required this.trackingNumber,
    this.senderName,
    this.buyerName,
    this.senderPhone,
    this.buyerPhone,
    this.comment,
    required this.deliveryTypeName,
    required this.pickupTypeName,
    this.senderFloor,
    this.buyerFloor,
    this.senderFlat,
    this.buyerFlat,
    required this.senderElevator,
    required this.buyerElevator,
    required this.paymentTypeName,
    required this.sellerName,
    required this.documentsReturn,
    required this.deliveryAddressName,
    required this.pickupAddressName,
    required this.packages,
    required this.cardPaymentAllowed,
    required this.needPayment,
    required this.factsConfirmed,
    this.storageId,
    required this.deliveryLoadDuration,
    required this.pickupLoadDuration,
    this.productArrivalName,
    this.productArrivalQR,
    required this.own,
    required this.needTransfer,
  });
}

mixin _$PaymentsDaoMixin on DatabaseAccessor<AppStorage> {
  $DeliveriesTable get deliveries => attachedDatabase.deliveries;
  $DeliveryPointsTable get deliveryPoints => attachedDatabase.deliveryPoints;
  $OrderStoragesTable get orderStorages => attachedDatabase.orderStorages;
  $OrdersTable get orders => attachedDatabase.orders;
  $DeliveryPointOrdersTable get deliveryPointOrders =>
      attachedDatabase.deliveryPointOrders;
  $PaymentsTable get payments => attachedDatabase.payments;
  Selectable<PaymentWithOrderResult> paymentWithOrder() {
    return customSelect(
        'SELECT"p"."id" AS "nested_0.id", "p"."delivery_point_order_id" AS "nested_0.delivery_point_order_id", "p"."summ" AS "nested_0.summ", "p"."transaction_id" AS "nested_0.transaction_id","dpo"."id" AS "nested_1.id", "dpo"."delivery_point_id" AS "nested_1.delivery_point_id", "dpo"."order_id" AS "nested_1.order_id", "dpo"."canceled" AS "nested_1.canceled", "dpo"."finished" AS "nested_1.finished", "dpo"."pickup" AS "nested_1.pickup","o"."id" AS "nested_2.id", "o"."delivery_date_time_from" AS "nested_2.delivery_date_time_from", "o"."delivery_date_time_to" AS "nested_2.delivery_date_time_to", "o"."pickup_date_time_from" AS "nested_2.pickup_date_time_from", "o"."pickup_date_time_to" AS "nested_2.pickup_date_time_to", "o"."number" AS "nested_2.number", "o"."tracking_number" AS "nested_2.tracking_number", "o"."sender_name" AS "nested_2.sender_name", "o"."buyer_name" AS "nested_2.buyer_name", "o"."sender_phone" AS "nested_2.sender_phone", "o"."buyer_phone" AS "nested_2.buyer_phone", "o"."comment" AS "nested_2.comment", "o"."delivery_type_name" AS "nested_2.delivery_type_name", "o"."pickup_type_name" AS "nested_2.pickup_type_name", "o"."sender_floor" AS "nested_2.sender_floor", "o"."buyer_floor" AS "nested_2.buyer_floor", "o"."sender_flat" AS "nested_2.sender_flat", "o"."buyer_flat" AS "nested_2.buyer_flat", "o"."sender_elevator" AS "nested_2.sender_elevator", "o"."buyer_elevator" AS "nested_2.buyer_elevator", "o"."payment_type_name" AS "nested_2.payment_type_name", "o"."seller_name" AS "nested_2.seller_name", "o"."documents_return" AS "nested_2.documents_return", "o"."delivery_address_name" AS "nested_2.delivery_address_name", "o"."pickup_address_name" AS "nested_2.pickup_address_name", "o"."packages" AS "nested_2.packages", "o"."card_payment_allowed" AS "nested_2.card_payment_allowed", "o"."need_payment" AS "nested_2.need_payment", "o"."facts_confirmed" AS "nested_2.facts_confirmed", "o"."storage_id" AS "nested_2.storage_id", "o"."delivery_load_duration" AS "nested_2.delivery_load_duration", "o"."pickup_load_duration" AS "nested_2.pickup_load_duration", "o"."product_arrival_name" AS "nested_2.product_arrival_name", "o"."product_arrival_q_r" AS "nested_2.product_arrival_q_r" FROM payments AS p JOIN delivery_point_orders AS dpo ON dpo.id = p.delivery_point_order_id JOIN orders AS o ON o.id = dpo.order_id',
        variables: [],
        readsFrom: {
          payments,
          deliveryPointOrders,
          orders,
        }).asyncMap((QueryRow row) async => PaymentWithOrderResult(
          p: await payments.mapFromRow(row, tablePrefix: 'nested_0'),
          dpo: await deliveryPointOrders.mapFromRow(row,
              tablePrefix: 'nested_1'),
          o: await orders.mapFromRow(row, tablePrefix: 'nested_2'),
        ));
  }
}

class PaymentWithOrderResult {
  final Payment p;
  final DeliveryPointOrder dpo;
  final Order o;
  PaymentWithOrderResult({
    required this.p,
    required this.dpo,
    required this.o,
  });
}

mixin _$UsersDaoMixin on DatabaseAccessor<AppStorage> {
  $OrderStoragesTable get orderStorages => attachedDatabase.orderStorages;
  $UsersTable get users => attachedDatabase.users;
}
