import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/services/FavoritesServices.dart';

void AddToFavoritesDialog(
    BuildContext context, String roomID, LatLng tappedLocation) {
  TextEditingController locationNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  String description = "Example: CCIS supermarket";
  locationNameController.text = roomID;

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: Color.fromARGB(255, 113, 110, 110),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 247, 246, 254),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    "Location Name",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF09186C),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 55,
                  child: Material(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(20),
                    child: TextFormField(
                      controller: locationNameController,
                      maxLength: 25,
                      decoration: InputDecoration(
                        hintText: roomID,
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Color.fromARGB(255, 124, 122, 122),
                        ),
                        counterText: '', // Hide max length counter
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF09186C),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 55,
                  child: Material(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(20),
                    child: TextFormField(
                      controller: descriptionController,
                      maxLength: 35,
                      decoration: InputDecoration(
                        hintText: "Example: CCIS supermarket",
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Color.fromARGB(255, 124, 122, 122),
                        ),
                        counterText: '', // Hide max length counter
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (locationNameController.text.isEmpty)
                        FavoriteLocationsService().saveLocationToFavorites(
                            tappedLocation,
                            roomID,
                            roomID,
                            descriptionController.text.toString());
                      else
                        FavoriteLocationsService().saveLocationToFavorites(
                            tappedLocation,
                            roomID,
                            locationNameController.text.toString(),
                            descriptionController.text.toString());

                      Navigator.pop(context);

                      print(
                          "inside AddToFavoritesDialog and the info of this location is roomID: ${locationNameController.text.toString()} , LatLng: $tappedLocation , description: ${descriptionController.text.toString()} ");
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF09186C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Add to favorites  ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                        Icon(Icons.favorite_rounded),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void editFavoritesDialog(BuildContext context, String locationName,
    String description, String roomID) {
  TextEditingController locationNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  locationNameController.text = locationName;
  descriptionController.text = description;

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: Color.fromARGB(255, 113, 110, 110),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 247, 246, 254),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    "Location Name",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF09186C),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 55,
                  child: Material(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(20),
                    child: TextFormField(
                      controller: locationNameController,
                      maxLength: 25,
                      decoration: InputDecoration(
                        hintText: locationName,
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Color.fromARGB(255, 124, 122, 122),
                        ),
                        counterText: '', // Hide max length counter
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    "Description",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF09186C),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 55,
                  child: Material(
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.70),
                    borderRadius: BorderRadius.circular(20),
                    child: TextFormField(
                      controller: descriptionController,
                      maxLength: 35,
                      decoration: InputDecoration(
                        hintText: "Example: CCIS supermarket",
                        hintStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                          color: Color.fromARGB(255, 124, 122, 122),
                        ),
                        counterText: '', // Hide max length counter
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (locationNameController.text.isEmpty)
                        FavoriteLocationsService().saveChanges(
                            roomID,
                            locationName,
                            descriptionController.text.toString());
                      else
                        FavoriteLocationsService().saveChanges(
                          roomID,
                          locationNameController.text.toString(),
                          descriptionController.text.toString(),
                        );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF09186C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Save Changes  ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 17,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      );
    },
  );
}
