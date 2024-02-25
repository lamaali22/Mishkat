import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/models/CCISBeacons.dart';
import 'package:vector_math/vector_math.dart' as vec;

class Location {
  LatLng currentLocation = LatLng(0, 0);

  Future<void> startScanning() async {
    Map<String, int> rssiValues = {};
    Map<String, double> distances = {};
    List<BluetoothDevice> devices = [];
    List<Beacon> scannedBeacons = [];

    CCISBeacons ccisBeacons = CCISBeacons();
    await ccisBeacons.initListOfBeacons();

    FlutterBluePlus.startScan(timeout: Duration(seconds: 3));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (!devices.contains(result.device) &&
            ccisBeacons.hasBeacon(result.device.remoteId.toString())) {
          devices.add(result.device);

          int rssi = result.rssi;
          String beaconId = result.device.remoteId.toString();
          rssiValues[beaconId] = rssi;

          Beacon scannedBeacon = ccisBeacons.getBeacon(beaconId);
          scannedBeacons.add(scannedBeacon);

          distances = calculateDistances(rssiValues);

          if (distances.length >= 1) {
            LatLng userLocation = await trilaterate(distances, scannedBeacons);
            print('Estimated User Location: $userLocation');
            currentLocation = userLocation;
            FlutterBluePlus.stopScan();
            break;
          }
        }
      }
    });
  }

  Map<String, double> calculateDistances(Map<String, int> rssiValues) {
    Map<String, double> distances = {};

    rssiValues.forEach((beaconId, rssi) {
      num distance = calculateDistance(rssi);
      distances[beaconId] = distance.toDouble();
      print('Distance of $beaconId: $distance meters');
    });

    return distances;
  }

  num calculateDistance(int rssi) {
    int measuredPower = -59;
    const double n = 2.5;
    return pow(10, ((measuredPower - rssi)) / (10 * n));
  }

  Future<LatLng> trilaterate(
      Map<String, double> distances, List<Beacon> beacons) async {
    List<vec.Vector2> beaconPositions = beacons
        .map((beacon) => vec.Vector2(
            beacon.coordinates.latitude, beacon.coordinates.longitude))
        .toList();

    List<double> knownDistances = distances.values.toList();

    vec.Vector2? estimatedLocation =
        await trilateration(beaconPositions, knownDistances);

    if (estimatedLocation != null) {
      return LatLng(estimatedLocation.x, estimatedLocation.y);
    } else {
      return LatLng(0, 0); // Default location
    }
  }

  Future<vec.Vector2?> trilateration(
      List<vec.Vector2> beacons, List<double> distances) async {
    if (beacons.length != distances.length) {
      print("Mismatch between beacons and distances");
      return null;
    }

    List<double> weights = distances.map((distance) => 1.0 / distance).toList();

    double sumX = 0.0, sumY = 0.0, totalWeight = 0.0;

    for (int i = 0; i < beacons.length; i++) {
      sumX += beacons[i].x * weights[i];
      sumY += beacons[i].y * weights[i];
      totalWeight += weights[i];
    }

    return vec.Vector2(sumX / totalWeight, sumY / totalWeight);
  }

  void stopScanning() {
    FlutterBluePlus.stopScan();
  }
}
