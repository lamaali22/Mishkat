import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mishkat/firebase_options.dart';
import 'package:mishkat/pages/roomInformation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Map Demo',
      home: MapScreen(title: 'Flutter Map Demo'),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapController mapController;
  List<Polygon> polygons;
  List<Marker> polygonLabels;

  _MapScreenState()
      : mapController = MapController(),
        polygons = [],
        polygonLabels = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: MediaQuery.of(context).size.height *
                  0.8, // Adjust the height as needed
              child: GestureDetector(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    center: LatLng(24.72337, 46.63664),
                    minZoom: 14.0,
                    zoom: 19,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    GestureDetector(
                      child: PolygonLayer(
                        polygons: polygons,
                      ),
                    ),
                    MarkerLayer(
                      markers: polygonLabels,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadGeoJson() async {
    final geoJsonString =
        await DefaultAssetBundle.of(context).loadString('assets/map.geojson');
    final geoJson = json.decode(geoJsonString);

    _convertAndDisplayPolygons(geoJson);
  }

  Future<void> _convertAndDisplayPolygons(Map<String, dynamic> geoJson) async {
    for (var feature in geoJson['features']) {
      if (feature['geometry']['type'] == 'Polygon') {
        // ... existing code ...
        List<LatLng> coordinates = [];

        for (var point in feature['geometry']['coordinates'][0]) {
          coordinates.add(LatLng(point[1], point[0]));
        }

        Color fillColor = _parseColor(feature['properties']['fill']);
        Color strokeColor = _parseColor(feature['properties']['stroke']);

        // Add Polygon
        setState(() {
          polygons.add(Polygon(
            points: coordinates,
            isFilled: true,
            color: fillColor.withOpacity(0.5),
            borderStrokeWidth: 1,
            borderColor: strokeColor,
            isDotted: false,
          ));
        });
        LatLng calculateAveragePosition(List<LatLng> coordinates) {
          double sumLat = 0.0;
          double sumLng = 0.0;

          for (var coord in coordinates) {
            sumLat += coord.latitude;
            sumLng += coord.longitude;
          }

          double avgLat = sumLat / coordinates.length;
          double avgLng = sumLng / coordinates.length;

          return LatLng(avgLat, avgLng);
        }

        // Add Polygon Label

        if (feature['properties']['roomId'] != null) {
          LatLng labelPosition = calculateAveragePosition(coordinates);
          // Get a reference to the Firestore document
          String roomId = feature['properties']['roomId'];
          String type = feature['properties']['type'];
          // this code might be used later

          // if (type == "classroom" ||
          //     type == "mariah auditorium" ||
          //     type == "khadijah auditorium")
          //   await _updateClassroomCoordinates(roomId, labelPosition);

          // if (type == "lab") await _updateLabCoordinates(roomId, labelPosition);
          // if (type == "office")
          //   await _updateOfficeCoordinates(roomId, labelPosition);
          // if (type != "classroom" &&
          //     type != "mariah auditorium" &&
          //     type != "khadijah auditorium" &&
          //     type != "lab")
          //   await _updateServiceCoordinates(roomId, labelPosition);
          setState(() {
            // Add Marker for label
            polygonLabels.add(Marker(
              point: labelPosition,
              builder: (ctx) => GestureDetector(
                onTap: () {
                  // Handle tap on the label
                  if (feature['properties']['type'] != null) {
                    _handleLabelTap(roomId, type, labelPosition);
                  }
                },
                child: Transform.translate(
                  //11goes down and the 3 left and right
                  offset: const Offset(9.0, 0.8),
                  child: Transform.rotate(
                    angle: -pi / 2,
                    child: Column(
                      children: [
                        if (feature['properties']['icon'] != null)
                          Image.network(
                            feature['properties']['icon'],
                            height: 15,
                            width: 15,
                          ),
// we might use this code later

                        // if (feature['properties']['type'] == 'service') ...[
                        //   FutureBuilder<DocumentSnapshot>(
                        //     future: FirebaseFirestore.instance
                        //         .collection('Services')
                        //         .doc(feature['properties']['roomId'])
                        //         .get(),
                        //     builder: (BuildContext context,
                        //         AsyncSnapshot<DocumentSnapshot> snapshot) {
                        //       if (snapshot.hasError) {
                        //         return Text("Error fetching data");
                        //       }

                        //       if (snapshot.connectionState ==
                        //           ConnectionState.done) {
                        //         Map<String, dynamic>? data = snapshot.data
                        //             ?.data() as Map<String, dynamic>?;

                        //         if (data != null) {
                        //           return Text(
                        //             data['serviceName'] ?? '',
                        //             style: const TextStyle(
                        //               color: Colors.black,
                        //               fontSize: 8.0,
                        //             ),
                        //             maxLines: 2,
                        //           );
                        //         } else {
                        //           return Text("Service not found");
                        //         }
                        //       }

                        //       return const CircularProgressIndicator(); // While loading
                        //     },
                        //   ),
                        // ] else ...[
                        Text(
                          feature['properties']['label'] ?? '',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 8.0,
                          ),
                          maxLines: 2,
                        ),
                        // ],
                      ],
                    ),
                  ),
                ),
              ),
            ));
          });
        }
      }
    }
  }

  Future<void> _handleLabelTap(
      String roomId, String type, LatLng position) async {
    String serviceName = '';
    String serviceType = '';
    String openTime = "";
    String closeTime = "";

    if (type == 'service') {
      try {
        // Query Firestore to get serviceName and serviceType from the "service" collection
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('Services')
            .doc(roomId)
            .get();

        // Check if the document exists
        if (snapshot.exists) {
          serviceName = snapshot['serviceName'];
          serviceType = snapshot['serviceType'];
          openTime = snapshot['opens'];
          closeTime = snapshot['closes'];
        } else {
          // Handle the case when the document does not exist
          print('Document does not exist');
        }
      } catch (e) {
        // Handle errors while fetching data
        print('Error fetching data: $e');
      }
    }

    // Show a dialog at the bottom of the screen
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (type != 'service') ...[
                  Text(
                    roomId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
                if (type == 'service') ...[
                  Text(
                    '$serviceName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  Text(
                    '$serviceType',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  if (serviceType == "Restaurant" || serviceType == "Market")
                    Text(
                      'opens from ' + '$openTime' + ' to ' + '$closeTime',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildButton("Directions", Icons.directions_outlined),
                      _buildButton("Save", Icons.bookmark_outline_outlined),
                      _buildButton("Favorite", Icons.star_border_outlined),
                      _buildButton("Share", Icons.ios_share),
                    ],
                  ),
                ),
                if (type == "lab" ||
                    type == "classroom" ||
                    type == "mariah auditorium" ||
                    type == "khadijah auditorium") ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _showScheduleDialog(roomId, type);
                    },
                    child: const Text(
                      "View room information",
                      style: TextStyle(
                        color: Color.fromARGB(255, 9, 24, 108),
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(255, 9, 24, 108),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                if (type == "office") ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _showOfficeMembersDialog(roomId);
                    },
                    child: const Text(
                      "View office's members",
                      style: TextStyle(
                        color: Color.fromARGB(255, 9, 24, 108),
                        decoration: TextDecoration.underline,
                        decorationColor: Color.fromARGB(255, 9, 24, 108),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
    // Move the map to the labelPosition with a specific zoom level
    mapController.move(position, 21.0);
  }

  Future<void> _showOfficeMembersDialog(String roomId) async {
    try {
      // Fetch the office data from Firestore using the roomId
      DocumentSnapshot officeSnapshot = await FirebaseFirestore.instance
          .collection('Office')
          .doc(roomId)
          .get();

      // Extract the list of faculties from the office data
      List<dynamic>? faculties = officeSnapshot['listOfFaculties'];

      // If faculties data is available, show the dialog
      if (faculties != null && faculties.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Office Members",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Color.fromARGB(255, 9, 24, 108),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Color.fromARGB(255, 9, 24, 108),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: List.generate(faculties.length, (index) {
                          // Extract name and department from each faculty map
                          String name = faculties[index]['name'];
                          String dept = faculties[index]['dept'];

                          // Determine box color based on department
                          Color boxColor;
                          switch (dept) {
                            case 'SWE':
                              boxColor = Color.fromARGB(255, 80, 112, 214);
                              break;
                            case 'IT':
                              boxColor = Color.fromARGB(255, 0, 170, 170);
                              break;
                            case 'IS':
                              boxColor = Color.fromARGB(255, 0, 133, 140);
                              break;
                            case 'CS':
                              boxColor = Color.fromARGB(255, 0, 101, 122);
                              break;
                            default:
                              boxColor = Color.fromARGB(255, 237, 128, 109);
                          }

                          // Format and display the faculty information
                          return Container(
                            margin: EdgeInsets.all(4.0),
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: boxColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              '$name - $dept',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            );
          },
        );
      } else {
        // Display a message in the dialog if no faculties data is available
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Office Members",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Color.fromARGB(255, 9, 24, 108),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Color.fromARGB(255, 9, 24, 108),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "No office members.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 9, 24, 108),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                ],
              ),
            );
          },
        );
      }
    } catch (error) {
      print('Error fetching office data: $error');
      // Handle error accordingly
    }
  }

  _showScheduleDialog(String roomId, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScheduleDialog(roomId: roomId, type: type);
      },
    );
  }

  Widget _buildButton(String label, IconData icon) {
    Color buttonColor;
    Color textColor;
    Color iconColor;

    if (label == "Directions") {
      buttonColor = const Color.fromARGB(255, 9, 24, 108);
      textColor = Colors.white;
      iconColor = Colors.white;
    } else {
      buttonColor = const Color.fromARGB(255, 229, 237, 255);
      textColor = const Color.fromARGB(255, 9, 24, 108);
      iconColor = const Color.fromARGB(255, 9, 24, 108);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            // Handle button press
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 9.0),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(color: textColor), // Adjust label color
                ),
                const SizedBox(width: 7.0),
                Icon(icon, color: iconColor), // Adjust icon color
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    // Check if the color string is in the valid format
    if (colorString.length == 7 && colorString.startsWith('#')) {
      return Color(int.parse(colorString.substring(1), radix: 16) + 0xFF000000);
    } else {
      // Default color if the format is not valid
      return Colors.transparent;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }
}
