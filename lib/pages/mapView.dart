import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mishkat/firebase_options.dart';
import 'package:mishkat/pages/roomInformation.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MapScreen(center: LatLng(24.723315121952027, 46.63643191673523)),
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
  List<Map<String, dynamic>> places = [];
  String selectedPlace = '';

  _MapScreenState()
      : mapController = MapController(),
        polygons = [],
        polygonLabels = [];

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

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
                    hintText: "Search",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 9, 24, 108),
                      ), // Adjust the radius as needed
                    ),
                  ),
                ),
                popupProps: PopupPropsMultiSelection.modalBottomSheet(
                  isFilterOnline: true,
                  showSelectedItems: true,
                  showSearchBox: true,
                  searchFieldProps: TextFieldProps(
                    style: TextStyle(fontSize: 12.0),
                    decoration: InputDecoration(
                      focusColor: Color.fromARGB(255, 9, 24, 108),
                      labelStyle: TextStyle(fontSize: 12.0),
                      floatingLabelStyle: TextStyle(fontSize: 12.0),
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

                    // Call handleLabelTap method with the required values
                    _handleLabelTap(roomId, type, position);
                  }
                },
              ),
            ),
          )),
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
              'position': labelPosition, // Generate a unique ID for each place
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
                            _handleLabelTap(roomId, type, labelPosition);
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
                                  // if (feature['properties']['icon'] != null)
                                  //   Image.network(
                                  //     feature['properties']['icon'],
                                  //     height: 13,
                                  //     width: 13,
                                  //   ),
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

  Future<void> _handleLabelTap(
      String roomId, String type, LatLng position) async {
    String serviceName = '';
    String serviceType = '';
    String openTime = "";
    String closeTime = "";
    bool isAvailable = await _isRoomAvailable(roomId, type);

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
                                190), // Adjust the spacing between roomId and availability status
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
                      _buildButton("Directions", Icons.directions_outlined),
                      _buildButton("Save", Icons.bookmark_outline_outlined,
                          onTap: () {}),
                      _buildButton("Favorite", Icons.star_border_outlined),
                      _buildButton(
                        "Share",
                        Icons.ios_share,
                        onTap: () {
                          print("pressed");
                          Share.share(
                              'look at this place https://www.google.com/maps/@${position.latitude},${position.longitude},15z ');
                        },
                      ),
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

//String url ='https://example.com/map?lat=${position.latitude}&lng=${position.longitude}&zoom=19';

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
          onTap: onTap,
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

  // @override
  // void initState() {
  //   super.initState();
  //   _loadGeoJson();
  // }
}
