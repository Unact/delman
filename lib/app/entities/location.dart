import 'package:equatable/equatable.dart';

import 'package:delman/app/utils/nullify.dart';

class Location extends Equatable {
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final double? altitude;
  final double? heading;
  final double? speed;
  final DateTime? pointTs;

  const Location({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.heading,
    this.speed,
    this.pointTs,
  });

  @override
  List<Object> get props => [];

  static Location fromJson(dynamic json) {
    return Location(
      latitude: Nullify.parseDouble(json['latitude']),
      longitude: Nullify.parseDouble(json['longitude']),
      accuracy: Nullify.parseDouble(json['accuracy']),
      altitude: Nullify.parseDouble(json['altitude']),
      heading: Nullify.parseDouble(json['heading']),
      speed: Nullify.parseDouble(json['speed']),
      pointTs: Nullify.parseDate(json['pointTs']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'heading': heading,
      'speed': speed,
      'pointTs': pointTs?.toIso8601String(),
    };
  }

  @override
  String toString() => 'Location { latitude: $latitude, longitude: $longitude }';
}
