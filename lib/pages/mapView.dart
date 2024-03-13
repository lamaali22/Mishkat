import 'dart:async';
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/services.dart';
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
import 'package:mishkat/services/ShareLocaion.dart';
import 'package:mishkat/services/shortestPath.dart';
import 'package:mishkat/widgets/FavoritesDialogs.dart';
import 'package:mishkat/widgets/Messages.dart';
import 'package:mishkat/widgets/MishkatNavigationBar.dart';
import 'package:mishkat/widgets/saveLocation.dart';

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
    return MaterialApp(
      title: 'Flutter Map Demo',
      home: MapScreen(center: LatLng(0, 0)),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.center}) : super(key: key);

  final LatLng center;

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
  List<Map<String, dynamic>> places = [];
  String selectedPlace = '';
  //to draw shortest path
  List<Polyline> polylines = [];

  _MapScreenState()
      : mapController = MapController(),
        polygons = [],
        polygonLabels = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.0), // Adjust the height as needed
          child: AppBar(
            backgroundColor:
                Colors.transparent, // Set background color to transparent
            elevation: 0, // Remove shadow
            flexibleSpace: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: DropdownSearch<String>(
                items: places.map<String>((place) => place['label']).toList(),

                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Search",
                    filled: false,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 9, 24, 108),
                      ), // Adjust the radius as needed
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  isFilterOnline: true,
                  showSelectedItems: true,
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                    decoration: InputDecoration(
                      focusColor: Color.fromARGB(255, 9, 24, 108),
                      labelStyle: TextStyle(
                        fontSize: 12.0,
                      ),
                      floatingLabelStyle: TextStyle(
                        fontSize: 12.0,
                        color: Color.fromARGB(255, 9, 24, 108),
                      ),
                      labelText: "Search",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 9, 24, 108),
                        ),
                      ),
                      fillColor: Color.fromARGB(255, 9, 24, 108),
                    ),
                  ),
                ),

                // mode: Mode.MENU,

                onChanged: (selectedPlace) {
                  // Find the index of the selected place
                  int selectedIndex = places
                      .indexWhere((place) => place['label'] == selectedPlace);

                  // Check if a corresponding place is found
                  if (selectedIndex != -1) {
                    // Extract the required values using the index
                    String roomId = places[selectedIndex]['roomId'];
                    String type = places[selectedIndex]['type'];
                    LatLng position = places[selectedIndex]['position'];
                    String label = places[selectedIndex]['label'];
                    // Call handleLabelTap method with the required values
                    _handleLabelTap(roomId, type, position, label);
                  }
                },
              ),
            ),
            toolbarHeight: 90, // Set the desired height here
            // Additional properties if needed
          )),
      bottomNavigationBar: CustomNavigationBar(index: 1),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height *
                        0.8, // Adjust the height as needed
                    child: FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        center: LatLng(24.723315121952027, 46.63643191673523),
                        minZoom: 14.0,
                        zoom: 19.3,
                        rotation: 57 * pi / 2, //new code
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
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future<void> _loadGeoJson() async {
    final geoJsonString =
        await DefaultAssetBundle.of(context).loadString('assets/map.geojson');
    final geoJson = json.decode(geoJsonString);

    _convertAndDisplayPolygons(geoJson);
  }

  String label1 = "";

  Future<void> _convertAndDisplayPolygons(Map<String, dynamic> geoJson) async {
    for (var feature in geoJson['features']) {
      if (feature['geometry']['type'] == 'Polygon') {
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

          if (type == 'service') {
            try {
              // Query Firestore to get serviceName
              DocumentSnapshot snapshot = await FirebaseFirestore.instance
                  .collection('Services')
                  .doc(roomId)
                  .get();

              // Check if the document exists
              if (snapshot.exists) {
                String serviceName = snapshot['serviceName'];
                // Update the label property based on serviceName
                feature['properties']['label'] = serviceName;
              } else {
                // Handle the case when the document does not exist
                print('Document does not exist');
              }
            } catch (e) {
              // Handle errors while fetching data
              print('Error fetching data: $e');
            }
          }

          if (feature['properties']['label'] != null &&
              feature['properties']['label'] != "unavailable") {
            String label = feature['properties']['label'];

            places.add({
              'position': labelPosition,
              'label': label,
              'type': type,
              'roomId': roomId,
            });
          }

          setState(() {
            // Add Marker for label
            polygonLabels.add(
              Marker(
                  point: labelPosition,
                  builder: (ctx) => GestureDetector(
                        onTap: () {
                          // Handle tap on the label
                          if (feature['properties']['type'] != null) {
                            if (feature['properties']['label'] != null)
                              label1 = feature['properties']['label'];
                            else
                              label1 = feature['properties']['roomId'];
                            _handleLabelTap(
                                roomId, type, labelPosition, label1);
                          }
                        },
                        child: Transform.scale(
                          scale: 0.08 * mapController.zoom,
                          child: Transform.translate(
                            //11goes down and the 3 left and right
                            offset: const Offset(10.0, 2),
                            child: Transform.rotate(
                              angle: -pi / 2,
                              child: Column(
                                children: [
                                  if (feature['properties']['icon'] != null)
                                    Image.network(
                                      feature['properties']['icon'],
                                      height: 13,
                                      width: 13,
                                    ),
                                  Text(
                                    feature['properties']['label'] ?? '',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 5.0,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400),
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
            );
          });
        }
      }
    }
  }

  late LatLng tappedLocation;

  Future<void> _handleLabelTap(
      String roomId, String type, LatLng position, String label) async {
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
                      _buildButton("Directions", Icons.directions_outlined,
                          onTap: () {
                        setState(() {
                          //shortestPath = [];
                          // polygons.clear();  // Clear any existing paths
                        });
                        // Trigger shortest path calculation
                        _calculateShortestPath();
                      }),
                      _buildButton("Save", Icons.bookmark_outline_outlined,
                          onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SaveLocationDialog(
                              roomId: roomId,
                              position: position,
                              label: label1,
                            );
                          },
                        );
                      }),
                      _buildButton("Favorite", Icons.star_border_outlined,
                          onTap: () {
                        if (tappedLocation != null) {
                          print("tappedloc not null and is $tappedLocation");
                          AddToFavoritesDialog(context, roomId, tappedLocation);
                        } else
                          print("tappedloc  null");
                      }),
                      _buildButton("Share", Icons.ios_share, onTap: () {
                        if (tappedLocation != null) {
                          print("tappedloc not null and is $tappedLocation");
                          shareLoc.createDynamicLink(tappedLocation);
                        } else
                          print("tappedloc  null");
                      }),
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
                        decorationThickness: 1.5,
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
                        decorationThickness: 1.5,
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
    if (widget.center != LatLng(0, 0)) {
      displayReceivedLocation(widget.center);
      print(
          "currentLatLng    ${widget.center.latitude}   ,  ${widget.center.longitude}");
    }

    periodicStartScanning();
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
                color: Colors.blue.withOpacity(0.28),
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
    print('user location isnt null at 925');
  }

  Marker? receivedLocationMarker;
  void displayReceivedLocation(LatLng sharedLatLng) {
    // Create a new marker
    // Create a new marker
    receivedLocationMarker = Marker(
      width: 48.0,
      height: 80.0,
      point: sharedLatLng,
      builder: (BuildContext context) {
        return Transform.rotate(
          angle: -90 * 3.1415926535 / 180,
          child: Icon(
            Icons.location_pin,
            size: 40.0,
            color: Color.fromARGB(255, 203, 59, 48),
          ),
        );
      },
    );
    // Add the new marker to the list of markers
    setState(() {
      polygonLabels.add(receivedLocationMarker!);
    });
    if (receivedLocationMarker == null) {
      // Move the camera to the user's location
      mapController.move(sharedLatLng, 25.0);
      print("ReceivedLocloaction is null");
    }
  }

// Modify the _calculateShortestPath method
  void _calculateShortestPath() async {
    // Ensure there is a user location and a tapped location
    if (userLocationMarker == null || tappedLocation == null) {
      print('userlocation is null ? ${userLocationMarker == null}');
      print('tappedlocation is null ? ${tappedLocation == null}');
      return;
    }

    // Calculate the shortest path using the ShortestPath class
    Set<String> calculatedShortestPath =
        await ShortestPath.calculateShortestPath(
            location.currentLocation, tappedLocation);

    print('calculatedShortestPath length is ${calculatedShortestPath}');
    // Display the shortest path on the map
    displayShortestPath(calculatedShortestPath);
  }

  static Future<void> displayShortestPath(
    // MapController mapController, // Map controller to control the map
    Set<String> pathVertices, // Set of path IDs representing the shortest path
  ) async {
    print("start displayshortestpath");

    MapController mapController;
    // Retrieve the GeoJSON data
    String geoJsonString = await rootBundle.loadString('assets/map.geojson');
    Map<String, dynamic> geoJson = json.decode(geoJsonString);

    // Iterate through the features in the GeoJSON data
    for (var feature in geoJson['features']) {
      // Check if the feature is a LineString and its ID is in pathVertices
      if (feature['geometry']['type'] == 'LineString' &&
          pathVertices.contains(feature['properties']['pathID'])) {
        // Extract coordinates from the feature
        List<LatLng> coordinates = [];
        for (var point in feature['geometry']['coordinates']) {
          coordinates.add(LatLng(point[1], point[0]));
        }

        // Create a polyline and add it to the map
        Polyline polyline = Polyline(
          points: coordinates,
          color: Colors.blue,
          strokeWidth: 4,
        );
        //  mapController.lines.add(polyline);
      }
    }
    print("end displayshortestpath");
  }

  Future<List<Polyline>> retrievePathGeometries(
    List<String> pathIds, // List of path IDs representing the shortest path
    Map<String, dynamic> geoJsonData, // GeoJSON data containing path geometries
  ) async {
    List<Polyline> polylines = [];

    // Iterate through the GeoJSON features to find the paths with matching IDs
    List<dynamic>? features = geoJsonData['features'] as List<dynamic>?;

    if (features != null) {
      features.forEach((feature) {
        if (feature['properties']['pathID'] != null &&
            pathIds.contains(feature['properties']['pathID'].toString())) {
          // Extract coordinates of the path
          List<dynamic> coordinates = feature['geometry']['coordinates'];
          List<LatLng> points = [];

          coordinates.forEach((coordinate) {
            points.add(LatLng(coordinate[1], coordinate[0]));
          });

          // Create a polyline from the coordinates
          Polyline polyline = Polyline(
            points: points,
            color: Colors.blue, // Dark blue color for the path
            strokeWidth: 4,
          );

          polylines.add(polyline);
        }
      });
    }

    return polylines;
  }
}
