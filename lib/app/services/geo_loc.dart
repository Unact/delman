import 'package:location/location.dart' as geo_loc;

import '/app/entities/entities.dart';

class GeoLoc {
  static Future<Location?> getCurrentLocation() async {
    geo_loc.Location loc = geo_loc.Location();

    if (!(await loc.serviceEnabled()) && !(await loc.requestService())) {
      return null;
    }

    if (
      await loc.hasPermission() == geo_loc.PermissionStatus.denied &&
      await loc.requestPermission() != geo_loc.PermissionStatus.granted
    ) {
      return null;
    }

    geo_loc.LocationData data = await loc.getLocation();

    return Location(
      latitude: data.latitude,
      longitude: data.longitude,
      accuracy: data.accuracy,
      altitude: data.altitude,
      heading: data.heading,
      speed: data.speed,
      pointTs: data.time != null ? DateTime.fromMillisecondsSinceEpoch(data.time!.toInt()) : null
    );
  }
}
