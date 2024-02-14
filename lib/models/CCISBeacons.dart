import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class CCISBeacons {
  //get these from the DB for testing purposes only
  List<Map<String, LatLng>> GBeacons_testing = [
    {'C3:00:00:16:F6:6B': LatLng(1.0, 2.0)}, // Beacon 1
    {'C3:00:00:16:F6:6A': LatLng(4.0, 2.0)}, // Beacon 2
    {'key3': LatLng(4.0, 2.0)}, // Beacon 3
    {'key4': LatLng(4.0, 2.0)}, // Beacon 4
    {'key5': LatLng(4.0, 2.0)}, // Beacon 5
    {'key6': LatLng(4.0, 2.0)}, // Beacon 6
    {'key7': LatLng(4.0, 2.0)}, // Beacon 7
    {'key8': LatLng(4.0, 2.0)}, // Beacon 8
    {'key9': LatLng(4.0, 2.0)}, // Beacon 9
    {'key10': LatLng(4.0, 2.0)}, // Beacon 10
  ];

  bool hasBeaconTest(String id) {
    print(
        " does a beacon with $id exists in the list of G Beacons ???     ${GBeacons_testing.any((Map<String, LatLng> beacon) => beacon.keys.contains(id))} ");
    return GBeacons_testing.any(
        (Map<String, LatLng> beacon) => beacon.keys.contains(id));
  }

  List<Beacon> GBeacons = [];

  bool hasBeacon(String id) {
    for (int i = 0; i < GBeacons.length; i++) {
      Beacon b = GBeacons[i];
      print(b);
      if (b.id == id) {
        print("Does a beacon with ${id} exist in the list of G Beacons? true");
        return true;
      }
    }
    print("Does a beacon with ${id} exist in the list of G Beacons? false");
    return false;
  }

  Future<void> fetchBeaconsFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot1 =
          await FirebaseFirestore.instance.collection('Classroom').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
          in querySnapshot1.docs) {
        String beaconID = documentSnapshot.get('beaconID');
        GeoPoint geoPoint = documentSnapshot.get('coordinates');
        LatLng coordinates = LatLng(geoPoint.latitude, geoPoint.longitude);

        Beacon beacon = Beacon(beaconID, coordinates);
        GBeacons.add(beacon);
        print(
            "CLASSROOM  beaconID ${beacon.id}   Coordinates : ${beacon.coordinates}");
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot2 =
          await FirebaseFirestore.instance.collection('Lab').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
          in querySnapshot2.docs) {
        String beaconID = documentSnapshot.get('beaconID');
        GeoPoint geoPoint = documentSnapshot.get('coordinates');
        LatLng coordinates = LatLng(geoPoint.latitude, geoPoint.longitude);

        Beacon beacon = Beacon(beaconID, coordinates);
        GBeacons.add(beacon);
        print(
            "LAB   beaconID ${beacon.id}   Coordinates : ${beacon.coordinates}");
      }
    } catch (e) {
      print('Error fetching beacons from Firebase: $e');
    }
  }
}

class Beacon {
  late String id;
  late LatLng coordinates;
  static const double measuredPower = -59;

  Beacon(this.id, this.coordinates);
}
