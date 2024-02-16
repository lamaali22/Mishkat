import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showUpdateSuccessMessage(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(
          'Your information has been updated successfully',
          style: TextStyle(
              color: Color.fromARGB(255, 5, 155, 85)), // Dark green text color
        ),
        duration: Duration(seconds: 6),
        backgroundColor:
            Color.fromARGB(255, 211, 225, 215), // Light green background color
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Make it appear at the top
        )),
  );
}

void showNoSignalAvailable(BuildContext context) {
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
          Center(
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFF09186C),
            ),
          ),
          SizedBox(height: 16), // Add some spacing
          Text(
            "Please ensure that your Bluetooth is enabled and try again later.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF09186C),
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: Container(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Container(
                width: 200,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color.fromARGB(255, 208, 213, 232),
                ),
                child: Text(
                  "OK",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 35, 51, 143),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
