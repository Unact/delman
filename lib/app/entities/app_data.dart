import 'package:equatable/equatable.dart';

import 'package:delman/app/utils/nullify.dart';

class AppData extends Equatable {
  final DateTime lastSyncTime;

  const AppData({this.lastSyncTime});

  @override
  List<Object> get props => [lastSyncTime];

  static AppData fromJson(dynamic json) {
    return AppData(
      lastSyncTime: Nullify.parseDate(json['lastSyncTime'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastSyncTime': lastSyncTime?.toIso8601String()
    };
  }

  @override
  String toString() => 'AppData { lastSyncTime: $lastSyncTime }';
}
