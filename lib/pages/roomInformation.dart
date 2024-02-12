import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ScheduleDialog extends StatefulWidget {
  final String roomId;

  final String type;

  const ScheduleDialog({Key? key, required this.roomId, required this.type})
      : super(key: key);

  @override
  _ScheduleDialogState createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<ScheduleDialog> {
  int selectedIndex = -1;
  late String selectedDay;

  Map<String, String> dayFields = {
    'Sun': 'sundayTimeslots',
    'Mon': 'mondayTimeslots',
    'Tue': 'tuesdayTimeslots',
    'Wed': 'wednesdayTimeslots',
    'Thu': 'thursdayTimeslots',
  };

  List<Widget> scheduleWidgets = [];

  Map<String, dynamic>? labData;

  @override
  void initState() {
    super.initState();
    selectedDay = 'Sun';
    selectedIndex = 0;
    if (widget.type == "lab") {
      displayLabSchedule(selectedDay);
    }
    if (widget.type == "classroom" ||
        widget.type == "mariah auditorium" ||
        widget.type == "khadijah auditorium") {
      displayClassSchedule(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(20.0), // Adjust the radius as needed
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 1.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Centered text at the top with roomId
                Center(
                  child: Text(
                    '${widget.roomId}' + ' occupation times',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Color.fromARGB(255, 9, 24, 108),
                    ),
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
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final day = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'][index];
                return Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex = index;
                          selectedDay = day;
                        });
                        if (widget.type == "classroom" ||
                            widget.type == "mariah auditorium" ||
                            widget.type == "khadijah auditorium") {
                          displayClassSchedule(selectedDay);
                        }
                        if (widget.type == "lab") {
                          displayLabSchedule(selectedDay);
                        }
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 10.0), // Adjust padding as needed
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          Size(65.0, 32.0), // Adjust button size as needed
                        ),
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (states) {
                            return index == selectedIndex
                                ? Color.fromARGB(255, 9, 24, 108)
                                : Color.fromARGB(255, 229, 237, 255);
                          },
                        ),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (states) {
                            return index == selectedIndex
                                ? Colors.white
                                : Color.fromARGB(255, 9, 24, 108);
                          },
                        ),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.0), // Add space between buttons
                  ],
                );
              }),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: Wrap(
                spacing: 8.0, // Horizontal spacing between boxes
                runSpacing: 8.0, // Vertical spacing between lines
                children: scheduleWidgets.isNotEmpty
                    ? scheduleWidgets
                    : [
                        Center(
                          child: Text(
                            selectedIndex != -1 ? '' : 'Choose a Day',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 9, 24, 108),
                            ),
                          ),
                        ),
                      ],
              ),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

// Function to fetch and display the schedule for the selected day
  void displayLabSchedule(String selectedDay) async {
    try {
      // Get the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Search for the document with the provided roomId
      DocumentSnapshot documentSnapshot =
          await firestore.collection('Lab').doc(widget.roomId).get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Get the field name based on the selected day
        String selectedDayField = dayFields[selectedDay] ?? '';

        // Retrieve the timeslots for the selected day
        Map<String, dynamic>? data =
            (documentSnapshot.data() as Map<String, dynamic>?) ?? {};

        // Initialize list of slots with timeslots
        List<Widget> slots = [];

        // If there are timeslots available, display them
        if (selectedDayField.isNotEmpty) {
          List<dynamic>? selectedDayTimeslots =
              data[selectedDayField]?.cast<Map<String, dynamic>>();
          if (selectedDayTimeslots != null && selectedDayTimeslots.isNotEmpty) {
            for (var slot in selectedDayTimeslots) {
              String from = slot['from'];
              String to = slot['to'];
              slots.add(Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 229, 237, 255),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$from - $to',
                          style: TextStyle(
                            color: Color.fromARGB(255, 9, 24, 108),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.0),
                ],
              ));
            }
          } else {
            // If no timeslots available, display a message
            slots.add(Center(
              child: Text(
                'No timeslots occupied',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 27, 40, 114),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ));
          }
        }

        // Display capacity and list of tools
        String capacity = data['capacity'].toString();
        List<dynamic>? tools = data['listOfTools'];
        String toolsString = '';
        if (tools != null && tools.isNotEmpty) {
          // Extract titles from the list of tools
          List<String> toolTitles = [];
          for (var tool in tools) {
            if (tool is Map<String, dynamic> && tool.containsKey('title')) {
              toolTitles.add(tool['title'].toString());
            }
          }
          toolsString = toolTitles.join(', ');
        }
// Capacity and tools widget
        Widget capacityAndToolsWidget = Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[400]!, // Adjust border color as needed
                    width: 1.0, // Adjust border width as needed
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Room capacity:',
                      style: TextStyle(
                        color: Color.fromARGB(255, 9, 24, 108),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(width: 3.0), // Add space between text and value
                    Text(
                      capacity,
                      style: TextStyle(
                        color: Color.fromARGB(255, 9, 24, 108),
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[400]!, // Adjust border color as needed
                    width: 1.0, // Adjust border width as needed
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tools:',
                      style: TextStyle(
                        color: Color.fromARGB(255, 9, 24, 108),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(width: 3.0), // Add space between text and value
                    Text(
                      toolsString.isEmpty ? 'No tools available' : toolsString,
                      style: TextStyle(
                        color: Color.fromARGB(255, 9, 24, 108),
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        // Update the UI with slots and capacity/tools widget
        setState(() {
          scheduleWidgets = [...slots, capacityAndToolsWidget];
        });
      } else {
        // If document not found, display a message
        setState(() {
          scheduleWidgets = [
            Text('Room ID not found.'),
          ];
        });
      }
    } catch (error) {
      // If error occurs, display the error message
      print('Error fetching schedule: $error');
      setState(() {
        scheduleWidgets = [
          Text('Error fetching schedule: $error'),
        ];
      });
    }
  }

  // Function to fetch and display the schedule for the selected day
  void displayClassSchedule(String selectedDay) async {
    try {
      // Get the Firestore instance
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Search for the document with the provided roomId
      DocumentSnapshot documentSnapshot =
          await firestore.collection('Classroom').doc(widget.roomId).get();

      // Check if the document exists
      if (documentSnapshot.exists) {
        // Retrieve the data from the document
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        // Retrieve the timeslots for the selected day
        String selectedDayField = dayFields[selectedDay] ?? '';
        List<dynamic>? selectedDayTimeslots =
            data[selectedDayField]?.cast<Map<String, dynamic>>();

        // Initialize list of slots with timeslots
        List<Widget> slots = [];

        // If there are timeslots available, display them
        if (selectedDayTimeslots != null && selectedDayTimeslots.isNotEmpty) {
          for (var slot in selectedDayTimeslots) {
            String from = slot['from'];
            String to = slot['to'];
            slots.add(Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 229, 237, 255),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$from - $to',
                        style: TextStyle(
                          color: Color.fromARGB(255, 9, 24, 108),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ));
          }
        } else {
          // If no timeslots available, display a message
          slots.add(Center(
            child: Text(
              'No timeslots occupied',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromARGB(255, 9, 24, 108),
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ));
        }
// Display room capacity
        String capacity = data['capacity'].toString();
        Widget capacityWidget = Center(
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400]!, // Adjust border color as needed
                width: 1.0, // Adjust border width as needed
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Room capacity:',
                  style: TextStyle(
                    color: Color.fromARGB(255, 9, 24, 108),
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(width: 8.0), // Add space between text and value
                Text(
                  capacity,
                  style: TextStyle(
                    color: Color.fromARGB(255, 9, 24, 108),
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        );

        // Update the UI with slots and capacity
        setState(() {
          scheduleWidgets = [...slots, capacityWidget];
        });
      } else {
        setState(() {
          scheduleWidgets = [
            Text('Room ID not found.'),
          ];
        });
      }
    } catch (error) {
      print('Error fetching schedule: $error');
      setState(() {
        scheduleWidgets = [
          Text('Error fetching schedule: $error'),
        ];
      });
    }
  }
}
