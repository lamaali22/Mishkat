import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/pages/mapView.dart';

class SavedPlacesPage extends StatefulWidget {
  @override
  _SavedPlacesPageState createState() => _SavedPlacesPageState();
}

class _SavedPlacesPageState extends State<SavedPlacesPage> {
  late List<Map<String, dynamic>> savedPlaces = [];
  late Map<String, bool> hasSavedRooms = {};

  @override
  void initState() {
    super.initState();
    fetchSavedPlaces();
  }

  void fetchSavedPlaces() {
    FirebaseFirestore.instance
        .collection('Member')
        .doc("g4molU09kwr4Xz3gX563")
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          List<dynamic>? listOfSavedClasses = data['listOfSavedClasses'];

          if (listOfSavedClasses != null) {
            setState(() {
              savedPlaces = List<Map<String, dynamic>>.from(listOfSavedClasses
                  .map((place) => Map<String, dynamic>.from(place)));

              for (final day in [
                'Sunday',
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday'
              ]) {
                hasSavedRooms[day] =
                    savedPlaces.any((place) => place['day'].contains(day));
              }
            });
          }
        }
      } else {
        print('Document does not exist');
      }
    }).catchError((error) {
      print('Error fetching document: $error');
    });
  }

  void deleteDay(String day) {
    FirebaseFirestore.instance
        .collection('Member')
        .doc("g4molU09kwr4Xz3gX563")
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        Map<String, dynamic>? data =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (data != null) {
          List<dynamic>? listOfSavedClasses = data['listOfSavedClasses'];

          if (listOfSavedClasses != null) {
            setState(() {
              savedPlaces = List<Map<String, dynamic>>.from(listOfSavedClasses
                  .map((place) => Map<String, dynamic>.from(place)));

              // Check if the saved room is associated with multiple days
              bool isAssociatedWithMultipleDays =
                  savedPlaces.any((place) => place['day'].length > 1);

              // If associated with multiple days, just remove association with this day
              if (isAssociatedWithMultipleDays) {
                savedPlaces.forEach((place) {
                  if (place['day'].contains(day)) {
                    place['day'].remove(day);
                  }
                });
              } else {
                // If associated with only one day, delete the entire entry from the database
                savedPlaces.removeWhere((place) => place['day'].contains(day));
              }

              // Update the data in Firestore
              FirebaseFirestore.instance
                  .collection('Member')
                  .doc("g4molU09kwr4Xz3gX563")
                  .update({
                'listOfSavedClasses': savedPlaces,
              });
            });
            // Reload the page after the deletion process
            fetchSavedPlaces();
          }
        }
      } else {
        print('Document does not exist');
      }
    }).catchError((error) {
      print('Error fetching document: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 9, 24, 108),
        centerTitle: true,
        title: Text('Saved Places'),
      ),
      body: ListView(
        children: [
          for (final day in [
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday'
          ])
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              padding: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                    color: Color.fromARGB(70, 0, 170, 170), width: 1.0),
                color: Color.fromARGB(75, 200, 250, 233),
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Container(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    day,
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 133, 146),
                    ),
                  ),
                ),
                children: [
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                    padding: EdgeInsets.all(3.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (final place in savedPlaces)
                          if (place['day'].contains(day))
                            ListTile(
                              title: Text(
                                '${place['label']}',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 133, 146),
                                ),
                              ),
                              subtitle: place['description'] != ''
                                  ? Text(
                                      '${place['description']}',
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 133, 146),
                                      ),
                                    )
                                  : null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.visibility,
                                        color:
                                            Color.fromARGB(255, 0, 133, 146)),
                                    onPressed: () {
                                      // Navigate to MapScreen with coordinates fetched from the database
                                      GeoPoint geoPoint = place[
                                          'coordinates']; // Assuming 'coordinates' is the key for GeoPoint in your database
                                      double latitude = geoPoint.latitude;
                                      double longitude = geoPoint.longitude;
                                      LatLng coordinates =
                                          LatLng(latitude, longitude);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MapScreen(center: coordinates),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: const Color.fromARGB(
                                            255, 217, 133, 127)),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Color.fromARGB(
                                                255, 242, 243, 247),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              side: BorderSide(
                                                color: Colors.transparent,
                                              ),
                                            ),
                                            //title: Text("Confirm Delete"),
                                            content: Text(
                                                "Are you sure you want to delete the place?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(
                                                      context); // Close the dialog
                                                },
                                                child: Container(
                                                  width: 100,
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Color.fromARGB(
                                                        255, 229, 237, 255),
                                                  ),
                                                  child: Text(
                                                    "Cancel",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color.fromARGB(
                                                          255, 35, 51, 143),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  deleteDay(day);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Container(
                                                  width: 100,
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Color.fromARGB(
                                                        255, 191, 54, 12),
                                                  ),
                                                  child: Text(
                                                    "Delete",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                        if (!hasSavedRooms.containsKey(day) ||
                            !hasSavedRooms[day]!)
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              'No saved rooms for this day',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 133, 146)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
