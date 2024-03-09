import 'package:latlong2/latlong.dart';
import 'dart:math';


class Hallway {
  final String pathID; // Unique identifier for the hallway
  final LatLng start; // ID of the starting place
  final LatLng end; // ID of the ending place
  final List<String> connectedTo;

  Hallway({
    required this.pathID,
    required this.start,
    required this.end,
    required this.connectedTo
  });

  // Factory method to create DirectionalHallway from Firestore data
  factory Hallway.fromFirestore(Map<String, dynamic> data) {
    return Hallway(
      pathID: data['pathID'],
      connectedTo: List<String>.from(data['connectedTo']),
      start: data['start'],
      end: data['end'],
    );
  }

  // Factory method to create DirectionalHallway from GeoJSON data
  factory Hallway.fromGeoJSON(Map<String, dynamic> data) {
    final coordinates = data['geometry']['coordinates'];
    final start = LatLng(coordinates[0][1], coordinates[0][0]);
    final end = LatLng(coordinates[1][1], coordinates[1][0]);

    return Hallway(
      pathID: data['properties']['pathID'].toString(),
      connectedTo: List<String>.from(data['properties']['connectedTo']),
      start: start,
      end: end,
    );
  }
}


class GeoPoint {
  final double latitude;
  final double longitude;

  GeoPoint(this.latitude, this.longitude);
}

double calculateHaversineDistance(GeoPoint point1, GeoPoint point2) {
  const earthRadius = 6371.0; // Earth radius in kilometers

  // Convert latitude and longitude from degrees to radians
  final lat1Rad = _degreesToRadians(point1.latitude);
  final lon1Rad = _degreesToRadians(point1.longitude);
  final lat2Rad = _degreesToRadians(point2.latitude);
  final lon2Rad = _degreesToRadians(point2.longitude);

  // Haversine formula
  final dlat = lat2Rad - lat1Rad;
  final dlon = lon2Rad - lon1Rad;

  final a = pow(sin(dlat / 2), 2) +
      cos(lat1Rad) * cos(lat2Rad) * pow(sin(dlon / 2), 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double _degreesToRadians(double degrees) {
  return degrees * pi / 180;
}
