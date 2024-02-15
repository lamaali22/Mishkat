import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mishkat/firebase_options.dart';
import 'package:mishkat/pages/roomInformation.dart';
import 'package:mishkat/services/BluetoothPermissions.dart';
import 'package:mishkat/services/CurrentLocation.dart';
import 'package:mishkat/services/indoorGraph.dart' ;
import 'package:mishkat/services/pathFindingHelper.dart';
import 'package:mishkat/widgets/Messages.dart';
import 'package:mishkat/widgets/MishkatNavigationBar.dart';
import 'package:dijkstra/dijkstra.dart';

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
  LatLng userLocation = LatLng(24.7231, 46.63682222);
  Location location = Location();
  List<LatLng> shortestPath = [];


  _MapScreenState()
      : mapController = MapController(),
        polygons = [],
        polygonLabels = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Color(0xFF09186C),
        title: Center(
          child: Text(
            "Map",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),

        toolbarHeight: 90, // Set the desired height here
        // Additional properties if needed
      ),
      bottomNavigationBar: CustomNavigationBar(index: 1),
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
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400),
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
late LatLng tappedLocation;

  Future<void> _handleLabelTap(
      String roomId, String type, LatLng position) async {
    String serviceName = '';
    String serviceType = '';
    String openTime = "";
    String closeTime = "";
    bool isAvailable = await _isRoomAvailable(roomId, type);
    tappedLocation = position;


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
      // Trigger shortest path calculation
     // _calculateShortestPath();
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
                  Row(
                    children: [
                      Text(
                        roomId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (type == "lab" || type == "classroom") ...[
                        SizedBox(
                            width:
                                175), // Adjust the spacing between roomId and availability status
                        Row(
                          children: [
                            Icon(
                              isAvailable ? Icons.circle : Icons.circle,
                              color: isAvailable ? Colors.green : Colors.red,
                              size: 12,
                            ),
                            SizedBox(
                                width:
                                    4), // Adjust the spacing between the circle icon and availability status
                            Text(
                              isAvailable ? "Available" : "Unavailable",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18.0,
                                  fontFamily: 'Poppins',
                                  decoration: TextDecoration.none),
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.normal),
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
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '$serviceType',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4),
                  if (serviceType == "Restaurant" || serviceType == "Market")
                    Text(
                      'opens from ' + '$openTime' + ' to ' + '$closeTime',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        decoration: TextDecoration.none,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                       _buildButton("Directions", Icons.directions_outlined, onTap: () {
  setState(() {
    shortestPath = [];
   // polygons.clear();  // Clear any existing paths
  });
  // Trigger shortest path calculation
  _calculateShortestPath();
}),


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
                        fontFamily: 'Poppins',
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
                        fontFamily: 'Poppins',
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

 Future<bool> _isRoomAvailable(String roomId, String type) async {
    DateTime now = DateTime.now();
    print("now: $now");

    // Extract the current day and time in HH:mm format
    String currentTime = DateFormat.Hm().format(now);
    print("current time: $currentTime");

    // Adjust the day of the week to match Firestore's indexing (Firestore starts the week on Sunday)
    int firestoreDayOfWeek = now.weekday;
    print("Firestore day of week: $firestoreDayOfWeek");
    String roomType = "";
    if (type != "classroom" &&
        type != "mariah auditorium" &&
        type != "khadijah auditorium" &&
        type != 'lab') return false;

    if (type == "classroom" ||
        type == "mariah auditorium" ||
        type == "khadijah auditorium") roomType = "Classroom";

    if (type == "lab") roomType = "Lab";
    // Get the Firestore document for the classroom
    DocumentSnapshot roomSnapshot =
        await FirebaseFirestore.instance.collection(roomType).doc(roomId).get();

    if (roomSnapshot.exists) {
      // Select the corresponding timeslots array based on the current day
      List<dynamic> timeslots = [];
      switch (firestoreDayOfWeek) {
        case 0: // Sunday
          timeslots = roomSnapshot['sundayTimeslots'];
          break;
        case 1: // Monday
          timeslots = roomSnapshot['mondayTimeslots'];
          break;
        case 2: // Tuesday
          timeslots = roomSnapshot['tuesdayTimeslots'];
          break;
        case 3: // Wednesday
          timeslots = roomSnapshot['wednesdayTimeslots'];
          break;
        case 4: // Thursday
          timeslots = roomSnapshot['thursdayTimeslots'];
          break;

        default:
        // Handle other cases if needed
      }

      // Check if there are any timeslots that intersect with the current time
      bool isAvailable = true; // Assume the room is available by default
      for (var timeslot in timeslots) {
        String fromTime = timeslot['from'];
        String toTime = timeslot['to'];

        // Check if the current time falls within the timeslot
        if (currentTime.compareTo(fromTime) >= 0 &&
            currentTime.compareTo(toTime) < 0) {
          // Current time is within a timeslot, so the room is unavailable
          isAvailable = false;
          break; // No need to check further
        }
      }

      return isAvailable;
    }

    // Room is available if not occupied in any time slot
    return true;
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
                            fontFamily: 'Poppins',
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
                                fontFamily: 'Poppins',
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
                            fontFamily: 'Poppins',
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
                        fontFamily: 'Poppins',
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

Widget _buildButton(String label, IconData icon, {VoidCallback? onTap}) {
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
        onTap: onTap, // Use the provided onTap callback
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
                style: TextStyle(
                  color: textColor,
                  fontFamily: 'Poppins',
                ), // Adjust label color
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

  //for debugging
  int scanningCounter = 0;
  @override
  void initState() {
    super.initState();
    BluetoothPermissions().initBluetooth();
    _loadGeoJson();
    periodicStartScanning();

//backup working code
    // Future.delayed(Duration(seconds: 5), () {
    //   location.startScanning();
    //   // if no ble signals
    //   if (location.currentLocation == LatLng(0, 0)) {
    //     // wait for 15 more seconds
    //     Future.delayed(Duration(seconds: 15), () {
    //       //if there is still no signals
    //       if (location.currentLocation == LatLng(0, 0)) {
    //         print("currentLocaoitn is in first check  0,0");
    //         showNoSignalAvailable(context);
    //       } //if signals were detected after 15 seconds
    //       else {
    //         displayUserCurrentLocation(location.currentLocation);
    //         print("displayUserCurrentLocation now called");
    //         print("mapview  currentLocation  ${location.currentLocation}");
    //       }
    //     });
    //   } // there are signals
    //   else {
    //     displayUserCurrentLocation(location.currentLocation);
    //     print("displayUserCurrentLocation now called");
    //     print("mapview  currentLocation  ${location.currentLocation}");
    //   }
    // });
    // print("Executing code every 10 seconds");
  }

  late Timer scanningTimer;
  void periodicStartScanning() {
    Future.delayed(Duration(seconds: 2), () {
      scanningTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        location.startScanning();
        scanningCounter++;
        print("scanningCounter $scanningCounter");
        Future.delayed(Duration(seconds: 4), () {
          // if no ble signals
          if (location.currentLocation == LatLng(0, 0)) {
            // wait for 15 more seconds
            Future.delayed(Duration(seconds: 15), () {
              //if there is still no signals
              if (location.currentLocation == LatLng(0, 0)) {
                print("currentLocaoitn is in first check  0,0");
                showNoSignalAvailable(context);
              } //if signals were detected after 15 seconds
              else {
                displayUserCurrentLocation(location.currentLocation);
                print("displayUserCurrentLocation now called");
                print("mapview  currentLocation  ${location.currentLocation}");
              }
            });
          } // there are signals
          else {
            displayUserCurrentLocation(location.currentLocation);
            print("displayUserCurrentLocation now called");
            print("mapview  currentLocation  ${location.currentLocation}");
          }
        });
        print("Executing code every 10 seconds");
      });
    });
  }

  @override
  void dispose() {
    // Stop scanning when the screen is disposed
    location.stopScanning();
    scanningTimer.cancel();
    print("inside dispose");
    super.dispose();
  }

// Declare a variable to store the user's location marker
  Marker? userLocationMarker;
  void displayUserCurrentLocation(LatLng userLocation) {
    // Remove the existing marker if it exists
    if (userLocationMarker != null) {
      setState(() {
        polygonLabels.remove(userLocationMarker);
      });
    }

    // Create a new marker
    userLocationMarker = Marker(
      width: 50.0,
      height: 50.0,
      point: userLocation,
      builder: (BuildContext context) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(0.28),
              ),
            ),
            Container(
              width: 20.0,
              height: 20.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
    // Add the new marker to the list of markers
    setState(() {
      polygonLabels.add(userLocationMarker!);
    });
    if (userLocationMarker == null) {
      // Move the camera to the user's location
      mapController.move(userLocation, 20.0);
      print("userloaction is null");
    }
  }

   //Helper method to display the shortest path on the map
  void _displayShortestPath(List<LatLng> shortestPath) {
    // Clear existing markers or overlays related to paths
   polygons.clear();
  print ('shortest path is not empty? ${shortestPath.isNotEmpty}');
    // Draw the path on the map
    if (shortestPath.isNotEmpty) {
      // Create a Polygon to represent the path
      final pathPolygon = Polygon(
        points: shortestPath,
        color: Colors.blue.withOpacity(0.5),
        borderStrokeWidth: 3.0,
        borderColor: Colors.blue,
        isDotted: false,
      );

      // Add the pathPolygon to the list of polygons
      setState(() {
        polygons.add(pathPolygon);
      });

      // Move the camera to the center of the path with an appropriate zoom level
      final centerOfPath = calculateCenterOfPath(shortestPath);
      mapController.move(centerOfPath, 18.0);
    }
  }


  // Helper method to calculate the center of the path
  LatLng calculateCenterOfPath(List<LatLng> path) {
    double sumLat = 0.0;
    double sumLng = 0.0;

    for (final point in path) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    final avgLat = sumLat / path.length;
    final avgLng = sumLng / path.length;

    return LatLng(avgLat, avgLng);
  }

// Helper method to check if a point is clear (not above the block)
bool _isPointClear(LatLng point) {
  // Example condition: Check if the latitude is below a certain threshold
  // You should replace this condition with your actual logic
  return point.latitude < 10.0; // Adjust the threshold as needed
}

void _calculateShortestPath() {
  print('inside calculateshortest path');
  // Ensure there is a user location and a tapped location
  if (userLocationMarker == null || tappedLocation == null) {
    print('userlocation is null ? ${userLocationMarker == null}');
    print('tappedlocation is null ? ${tappedLocation == null}');
    return;
  }

  // Create an IndoorGraph with vertices as LatLng points
  IndoorGraph graph = IndoorGraph({}, {});
  print('graph is here ${graph.nodes}');
print(graph);
 // Add user location and tapped location as nodes
print('User location marker: ${userLocationMarker!.point}');
print('Tapped location: $tappedLocation');
graph.addNode("user", userLocationMarker!.point);
graph.addNode("tapped", tappedLocation);

  // Add edges between the vertices based on your map data
// Modify this part based on your actual map data and structure
for (Polygon polygon in polygons) {
  for (LatLng point in polygon.points) {
    // Check if the point is clear (not above the block)
    //if (_isPointClear(point)) {
      print('Adding node and connection for point: $point');
      graph.addNode(point.toString(), point);
      graph.addConnection("user", point.toString());
      graph.addConnection("tapped", point.toString());
   // }
  }
}

  print('graph is here3 ${graph.nodes}');

  // Calculate the shortest path using Dijkstra's algorithm
  DijkstraResult result = dijkstra(graph, "user", "tapped");
 if (result == null) {
    print('Error: Dijkstra result is null');
    return;
  }
   print('Dijkstra result: $result');

  // Extract the calculated shortest path as LatLng points
  List<LatLng> calculatedShortestPath = result.previousNodes.keys
      .where((node) => result.previousNodes[node] != null)
      .map((node) => graph.nodes[node]!)
      .toList();

 if (calculatedShortestPath.isEmpty) {
    print('Error: Calculated shortest path is empty');
    return;
  }
    setState(() {
    shortestPath = calculatedShortestPath;
  });

  // Display the shortest path on the map
  _displayShortestPath(shortestPath);
}


}
