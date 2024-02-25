import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class CCISBeacons {
  //get these from the DB for testing purposes only
  List<Map<String, LatLng>> GBeacons_testing = [
    {'C3:00:00:16:F6:6B': LatLng(1.0, 2.0)}, // Beacon 1
    {'key2': LatLng(4.0, 2.0)}, // Beacon 2
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

  initListOfBeacons() {
        GBeacons.clear(); // Clear existing beacons

    Beacon beacon1 = Beacon(
        "C3:00:00:16:F6:6A", LatLng(24.72310298632339, 46.6367800776951));// G46
    Beacon beacon2 = Beacon(
        "C3:00:00:16:F6:63", LatLng(24.723102823004517 ,  46.63684049351268));//g47
    // Beacon beacon3 = Beacon(
    //     "C3:00:00:16:F6:E1", LatLng(24.723102051450467 , 46.63688520863096));// g48
    Beacon beacon4 = Beacon(
        "C3:00:00:16:F6:64", LatLng(24.72313690713031, 46.636877745177344));//g1W
    // Beacon beacon5 = Beacon(
    //     "C3:00:00:16:F5:67", LatLng(24.723167, 46.636944)); //g50
    Beacon beacon6 = Beacon(
        "C3:00:00:16:F5:68", LatLng(24.723278, 46.636944)); //g51 avg
    // Beacon beacon7 = Beacon(
    //     "C3:00:00:16:F5:6B", LatLng(24.723306, 46.637000)); //g51 entrance   
    GBeacons.add(beacon1);
    GBeacons.add(beacon2);
    // GBeacons.add(beacon3);
    GBeacons.add(beacon4);
    // GBeacons.add(beacon5);
    GBeacons.add(beacon6);
    // GBeacons.add(beacon7);
  }

  bool hasBeacon(String id) {
    // for (int i = 0; i < GBeacons.length; i++) {
    //   Beacon b = GBeacons[i];
    //   if (b.id == id) {
    //     print("Does a beacon with ${b.id} exist in the list of G Beacons? true");
    //     print("the loop is ${i}");
    //     return true;
    //   }
    // }
    // //print("Does a beacon with ${id} exist in the list of G Beacons? false");
    // return false;
    return GBeacons.any((Beacon b) => b.id == id);
  }

  Beacon getBeacon(String id) {
    Beacon beacon = GBeacons.first;
    for (int i = 0; i < GBeacons.length; i++) {
      Beacon b = GBeacons[i];
      if (b.id == id) {
        beacon = b;
        return beacon;
      }
    }
    return beacon;
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
