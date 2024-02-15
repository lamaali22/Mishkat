import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:dart_numerics/dart_numerics.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/models/CCISBeacons.dart';
import 'package:vector_math/vector_math.dart' as vec;

class Location {
  LatLng currentLocation = LatLng(0, 0);

  startScanning() async {
    Map<String, int> rssiValues =
        {}; // list rssi and corresponding beacon MAC ID
    Map<String, double> distances =
        {}; // list of distances between each beacon and the user's device
    List<BluetoothDevice> devices =
        []; //list of Bluetooth Devices that the user's device is scanning from
    List<Beacon> scannedBeacons = [];

    // --   for trsting purposes only  --
    CCISBeacons ccisBeacons = CCISBeacons();
    ccisBeacons.initListOfBeacons();

    print("length of Gbeacons is ${ccisBeacons.GBeacons.length}");
    print("list of Gbeacons is ${ccisBeacons.GBeacons.toString()}");
        for (Beacon beacon in ccisBeacons.GBeacons) {
      print('Beacon id: ${beacon.id}, RSSI: ${beacon.coordinates}');
    }



    FlutterBluePlus.startScan(timeout: Duration(seconds: 3));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        print('rssi ${result.device.remoteId}');
        // Step 1: Take the scanned ble signal that come from our devices ONLY
        if (!devices.contains(result.device) &&
            ccisBeacons.hasBeacon(result.device.remoteId.toString())) {
          devices.add(result.device);
print('in step1 ' );
print(!devices.contains(result.device));
print(ccisBeacons.hasBeacon(result.device.remoteId.toString()));

          // Step 2: Store RSSI value associated with its beacon ID
          int rssi = result.rssi;
          String beaconId = result.device.remoteId.toString();
          rssiValues[beaconId] = rssi;
          Beacon scannedBeacon =
              ccisBeacons.getBeacon(result.device.remoteId.toString());
          scannedBeacons.add(scannedBeacon);
          print("scannedBeacons length  ${scannedBeacons.length}");
          print(
              "beaconId:  $beaconId  rssi:   $rssi   rssiValues length:  ${rssiValues.length}");

          // Step 3: Convert RSSI values to distances
          rssiValues.forEach((beaconId, rssi) {
            num distance = calculateDistance(rssi);
            distances[beaconId] = distance.toDouble();

            print(
                "distance  $distance    of beacon :   $beaconId      of rssi:   $rssi");
          });

          // Print the calculated distances
          distances.forEach((beaconId, distance) {
            print(
                '$beaconId - Estimated Distance: ${distance.toStringAsFixed(2)} meters');
          });

          //Step 4: After having enough data perform trilateration
          if (rssiValues.length >= 1) {
            LatLng userLocation = trilaterate(distances, scannedBeacons);
            print('Estimated User Location in Currentloc class: $userLocation');
            currentLocation = userLocation;
            FlutterBluePlus.stopScan();
            break;
          }
        }
      }
    });
  }

  // Function #1 to convert RSSI to distance
  num calculateDistance(int rssi) {
    // RSSI at 1 meter (reference distance)
    // const double referenceRSSI = -50;

    // measured power
    int measuredPower = -59;

    // Path loss exponent (free space path loss model)
    const double n = 2.5;

    // num distance = pow(10, ((referenceRSSI - rssi) - txPower) / (10 * n));
    num distance = pow(10, ((measuredPower - rssi)) / (10 * n));

    return distance;
  }

  // Function #2 to convert RSSI to distance
  num rssiToDistance(int rssi) {
    // RSSI at 1 meter (measured in dBm)
    double referenceRssi = -59.0;
    double n = 2.3;

    // Calculate the path loss
    double pathLoss = referenceRssi - rssi;

    // Calculate the estimated distance using the Log-Distance Path Loss Model
    num distance = pow(
        10,
        (pathLoss + (27.55 - 20 * log10(2400)) + (n - 2) * 10 * log10(2400)) /
            (10 * n));

    return distance;
  }

  LatLng trilaterate(Map<String, double> distances, List<Beacon> beacons) {
    List<vec.Vector2> beaconPositions = beacons
        .map((beacon) => vec.Vector2(
            beacon.coordinates.latitude, beacon.coordinates.longitude))
        .toList();

    List<double> knownDistances = distances.values.toList();

    // Perform trilateration
    vec.Vector2? estimatedLocation =
        trilateration(beaconPositions, knownDistances);

    if (estimatedLocation != null) {
      return LatLng(estimatedLocation.x, estimatedLocation.y);
    } else {
      // Handle the case where trilateration fails
      return LatLng(0, 0); // Default location
    }
  }

  vec.Vector2? trilateration(
      List<vec.Vector2> beacons, List<double> distances) {
    // Check if the number of beacons and distances match
    if (beacons.length != distances.length) {
      print("مقلب");
      return null; // Unable to perform trilateration
    }

    // Calculate weights based on inverse distance
    List<double> weights = distances.map((distance) => 1.0 / distance).toList();

    // Weighted average of x and y coordinates
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
