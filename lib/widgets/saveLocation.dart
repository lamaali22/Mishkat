import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SaveLocationDialog extends StatefulWidget {
  final String roomId;
  final LatLng position;
  final String label;

  SaveLocationDialog(
      {required this.roomId, required this.position, required this.label});

  @override
  _SaveLocationDialogState createState() => _SaveLocationDialogState();
}

class _SaveLocationDialogState extends State<SaveLocationDialog> {
  List<String> selectedDays = [];
  String description = '';

  @override
  Widget build(BuildContext context) {
    print("selected");
    return Material(
      // Wrap your dialog with Material widget
      color: Colors.transparent, // Make Material widget transparent
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 1.0),
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Save Location ${widget.roomId}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 9, 24, 108),
                    ),
                  ),
                ),
                _buildCheckboxes(),
                Row(
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 9, 24, 108),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Enter Description',
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 12.0,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 229, 237, 255)),
                        fixedSize:
                            MaterialStateProperty.all<Size>(Size(147, 43)),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 9, 24, 108)),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedDays.isEmpty) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                              'Please select at least one day.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ));
                          return;
                        }
                        _saveLocation(widget.roomId, widget.position,
                            widget.label, selectedDays, description);
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 9, 24, 108),
                          ),
                          fixedSize:
                              MaterialStateProperty.all<Size>(Size(147, 43))),
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title) {
    double width = 135;
    if (title == 'Monday')
      width = 140; // Adjust width for Sunday

    else if (title == "Tuesday")
      width = 142;
    else if (title == "Wednesday")
      width = 162;
    else if (title == "Thursday") width = 147;
    return Container(
      // Adjust the width as needed

      width: width,
      child: CheckboxListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        activeColor: Color.fromARGB(255, 9, 24, 108),
        value: selectedDays.contains(title),
        onChanged: (value) {
          setState(() {
            if (value != null && value) {
              selectedDays.add(title);
            } else {
              selectedDays.remove(title);
            }
          });
        },
        title: Text(
          title,
          style: TextStyle(
              color: Color.fromARGB(255, 9, 24, 108),
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Container(
      height: 60, // Adjust the height as needed
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildCheckbox('Sunday'),
          _buildCheckbox('Monday'),
          _buildCheckbox('Tuesday'),
          _buildCheckbox('Wednesday'),
          _buildCheckbox('Thursday'),
        ],
      ),
    );
  }

  void _saveLocation(String roomId, LatLng position, String label,
      List<String> selectedDays, String description) {
    Map<String, dynamic> newData = {
      'roomId': roomId,
      'coordinates': GeoPoint(position.latitude, position.longitude),
      'day': selectedDays,
      'description': description,
      'label': label,
    };
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('Member').doc("g4molU09kwr4Xz3gX563").update({
      'listOfSavedClasses': FieldValue.arrayUnion([newData]),
    }).then((value) {
      print('Data saved successfully!');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location saved successfully!'),
        ),
      );
    }).catchError((error) {
      print('Failed to save data: $error');
    });
  }
}
