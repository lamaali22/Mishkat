/*import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Page')),
      body: Center(
        child: Text('Welcome to the Home Page!'),
      ),
    );
  }
}*/import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mishkat/pages/OtpVerfication.dart';
import 'package:mishkat/pages/phonNumberPage.dart'; 

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF09186C),
        title: Text(
          "Home Page",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        toolbarHeight: 90, // Set the desired height here
        // Additional properties if needed
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.zero,
            width: 428,
            height: 926,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Colors.white,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Mishkat',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF09186C),
                  ),
                ),
                SizedBox(height: 10), // Add some space between the texts
                Text(
                  'Your indoor navigator in KSU',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF09186C), // Adjust color if needed
                  ),
                ),
                SizedBox(height: 20), // Add some space between the texts and the text field
                Container(
                  width: 300, // Adjust width as needed
                  child: TextField(
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: '+966 5XXXXXXXX',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 184, 214, 239), // Border color
                        ),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF1F4FF),
                    ),
                  ),
                
                ),
                SizedBox(height: 20), // Add some space between the text field and the buttons
                SizedBox(
                  width: 290, // Set width to 39 pixels
                  height: 50, // Set height to 603 pixels
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to OtpVerification page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PhoneNumberPage()),
                      );
                    },
                    child: Text('Sign in'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF09186C),
                      onPrimary: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10), // Add some space before the "or" text
                Text(
                  'or',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF09186C), // Adjust color if needed
                  ),
                ),
                SizedBox(height: 10), // Add some space after the "or" text
                SizedBox(
                  width: 290, // Set width to 290 pixels
                  height: 50, // Set height to 50 pixels
                  child: ElevatedButton(
                  onPressed: () {
                      // Navigate to MapView page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PhoneNumberPage()),
                      );
                    },
                    child: Text('Continue as guest'),
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF09186C),
                      onPrimary: Colors.white,
                    ),
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