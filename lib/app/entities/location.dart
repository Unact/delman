part of 'entities.dart';

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
  List<Object?> get props => [
    latitude,
    longitude,
    accuracy,
    altitude,
    heading,
    speed,
    pointTs,
  ];

  factory Location.fromJson(dynamic json) {
    return Location(
      latitude: Parsing.parseDouble(json['latitude']),
      longitude: Parsing.parseDouble(json['longitude']),
      accuracy: Parsing.parseDouble(json['accuracy']),
      altitude: Parsing.parseDouble(json['altitude']),
      heading: Parsing.parseDouble(json['heading']),
      speed: Parsing.parseDouble(json['speed']),
      pointTs: Parsing.parseDate(json['pointTs']),
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
