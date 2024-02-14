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
}*/import 'package:flutter/material.dart';

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
                      labelText: 'Enter your mobile number',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.blue, // Border color
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.lightBlue[100], // Background color
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

