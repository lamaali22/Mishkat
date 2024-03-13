import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/pages/mapView.dart';
import 'package:mishkat/services/FavoritesServices.dart';
import 'package:mishkat/widgets/FavoritesDialogs.dart';
import 'package:mishkat/widgets/MishkatNavigationBar.dart';

class FavoritesScreen extends StatefulWidget {
  final int index;

  FavoritesScreen({required this.index});

  @override
  _FavoritesScreen createState() => _FavoritesScreen();
}

class _FavoritesScreen extends State<FavoritesScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final Color iconAndTextColor = Color(0xFF09186C);
  final Color deleteIconAndTextColor = Color(0xFFBF360C);

  @override
  Widget build(BuildContext context) {
    if (widget.index == 2)
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: iconAndTextColor,
          title: Center(
            child: Text(
              "Favorites",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
          toolbarHeight: 90, // Set the desired height here
          // Additional properties if needed
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 15), // Adjust the height for spacing
                  ContainerList(),
                ],
              ),
            ),
            Positioned(
              top: -9,
              left: MediaQuery.of(context).size.width / 2 - 27.5,
              child: GestureDetector(
                onTap: () {
                  handleAdd();
                },
                child: Container(
                  width: 59,
                  height: 59,
                  margin:
                      EdgeInsets.only(top: 20), // Adjust the margin for spacing
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 8, 21, 93),
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Color.fromARGB(255, 45, 74, 153).withOpacity(0.30),
                        offset: Offset(0, 7),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavigationBar(
          index: widget.index,
        ),
      );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF09186C),
        title: Text(
          "Favorites",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        toolbarHeight: 90,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            // Add your logic to handle the back action
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 15), // Adjust the height for spacing
                ContainerList(),
              ],
            ),
          ),
          Positioned(
            top: -9,
            left: MediaQuery.of(context).size.width / 2 - 27.5,
            child: GestureDetector(
              onTap: () {
                handleAdd();
              },
              child: Container(
                width: 59,
                height: 59,
                margin:
                    EdgeInsets.only(top: 20), // Adjust the margin for spacing
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 8, 21, 93),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 45, 74, 153).withOpacity(0.30),
                      offset: Offset(0, 7),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Color.fromARGB(255, 255, 255, 255),
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBar(
        index: widget.index,
      ),
    );
  }

  void handleAdd() {
    print("inside handleAdd");
  }
}

class ContainerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FavoriteLocationsService().fetchListOfFavorites(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No data available.');
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(snapshot.data!.length, (index) {
              // Access data from snapshot.data[index] and display in your list
              Map<String, dynamic> data = snapshot.data![index];
              String locationName = data['locationName'];
              String description = data['description'];
              String roomID = data['roomID'];
              GeoPoint geoPoint = data["coordinates"];
              LatLng coords = LatLng(geoPoint.latitude, geoPoint.longitude);
              return GestureDetector(
                onTap: () {
                  // Handle click for each item
                  handleClicked();
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 113,
                      margin: EdgeInsets.only(
                        right: 30,
                        left: 30,
                        top: 30,
                        bottom: 5,
                      ),
                      padding: EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 0,
                        bottom: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F6F9),
                        border: Border.all(
                          color: Color.fromARGB(0, 203, 214, 255),
                          width: 0.4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: Offset(0, 3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 24, left: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  locationName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1F41BB),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 119, 132, 181),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            children: [
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_horiz,
                                  color: Color.fromARGB(255, 152, 144, 144),
                                ),
                                itemBuilder: (BuildContext context) {
                                  return [
                                    PopupMenuItem<String>(
                                      value: 'Edit',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.edit_outlined,
                                            color: Color(0xFF1F41BB),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Edit',
                                            style: TextStyle(
                                              color: Color(0xFF1F41BB),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'Delete',
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                              color: Color(0xFFBF360C),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Color(0xFFBF360C),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                                onSelected: (String value) {
                                  if (value == 'Edit') {
                                    print(
                                        "edit info is : locationName: $locationName description: $description  roomID: $roomID");
                                    handleEdit(context, locationName,
                                        description, roomID);
                                  } else if (value == 'Delete') {
                                    handleDelete(context, roomID);
                                  }
                                },
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              GestureDetector(
                                onTap: () {
                                  handleGotoLocation(context, coords);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 245, 245, 247),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        offset: Offset(0, 3),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Color.fromARGB(255, 48, 132, 69),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        }
      },
    );
  }

  void handleGotoLocation(BuildContext context, LatLng coords) {
    print(" inside handleGotoLocation");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          center: coords,
        ),
      ),
      (route) =>
          false, // This predicate will remove all the routes from the stack
    );
  }

  void handleEdit(BuildContext context, String locationName, String description,
      String roomID) {
    editFavoritesDialog(context, locationName, description, roomID);
    print("inside handleEdit");
  }

  void handleDelete(BuildContext context, String roomID) {
    print("inside handleDelete");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Colors.transparent,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16), // Add some spacing
            Text(
              "Do you want to delete this location from your favorites?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF09186C),
              ),
            ),
          ],
        ),
        actions: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 229, 229, 232),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 83, 86, 105),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 249, 231, 231),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () {
                    FavoriteLocationsService().deleteLocation(roomID);
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 176, 63, 63),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void handleClicked() {
    print("inside handleClicked ");
  }
}
