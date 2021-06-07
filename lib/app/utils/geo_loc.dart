import 'package:location/location.dart' as geoLoc;

import 'package:delman/app/entities/entities.dart';

class GeoLoc {
  static Future<Location?> getCurrentLocation() async {
    geoLoc.Location loc = new geoLoc.Location();

    if (!(await loc.serviceEnabled()) && !(await loc.requestService())) {
      return null;
    }

    if (
      await loc.hasPermission() == geoLoc.PermissionStatus.denied &&
      await loc.requestPermission() != geoLoc.PermissionStatus.granted
    ) {
      return null;
    }

    geoLoc.LocationData data = await loc.getLocation();

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
