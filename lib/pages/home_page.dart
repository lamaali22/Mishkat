import 'dart:collection';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mishkat/pages/mapView.dart';
import 'package:mishkat/pages/otpVerification.dart';
import 'package:mishkat/services/authService.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final TextEditingController phoneConrtoller = TextEditingController();
  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  final TextEditingController phoneNumberController = TextEditingController();
  Country selectedCountry = Country(
      phoneCode: "966",
      countryCode: "SA",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Saudi Arabia",
      example: "Saudi Arabia",
      displayName: "Saudi Arabia",
      displayNameNoCountryCode: "KSA",
      e164Key: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Color(0xFF09186C),
      //   title: Text(
      //     "Home Page",
      //     style: TextStyle(
      //       fontWeight: FontWeight.w500,
      //       color: Colors.white,
      //     ),
      //   ),
      //   toolbarHeight: 90, // Set the desired height here
      //   // Additional properties if needed
      // ),
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
                Image.asset(
                  'assets/logo.png',
                  height: 230,
                  width: 230,
                ),
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
                SizedBox(height: 20),
                Container(
                  width: 290,
                  child: // Add some space between the texts and the text field
                      TextFormField(
                    controller: phoneNumberController,
                    keyboardType: TextInputType.phone,
                    onChanged: (value) {
                      setState(() {
                        phoneNumberController.text = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Phone number cannot be empty';
                      }
                      if (value.length != 9) {
                        return 'Phone number must have 9 digits';
                      }
                      return null; // Return null if the input is valid
                    },
                    decoration: InputDecoration(
                      hintText: "Enter phone number",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF09186C),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF09186C),
                        ),
                      ),
                      prefixIcon: Container(
                        padding: const EdgeInsets.all(11.0),
                        child: InkWell(
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              countryListTheme: const CountryListThemeData(
                                bottomSheetHeight: 500,
                              ),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              },
                            );
                          },
                          child: Text(
                            "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      suffixIcon: phoneNumberController.text.length == 9
                          ? Container(
                              height: 30,
                              width: 30,
                              margin: const EdgeInsets.all(10.0),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: const Icon(
                                Icons.done,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                    height:
                        20), // Add some space between the text field and the buttons
                SizedBox(
                  width: 290, // Set width to 39 pixels
                  height: 50, // Set height to 603 pixels
                  child: ElevatedButton(
                    onPressed: () => sendPhoneNumber(),
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
                        MaterialPageRoute(
                            builder: (context) =>
                                MapScreen(title: 'Flutter Map GeoJson Demo')),
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

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void sendPhoneNumber() {
    final as = Provider.of<AuthService>(context, listen: false);
    String phoneNumber = phoneNumberController.text.trim();
    if (phoneNumber.isEmpty)
      _showSnackbar('Enter your phone number');
    else if (phoneNumber.length != 9)
      _showSnackbar('phone number shall be 9-Digits');
    else
      as.signInWithPhone(context, "+${selectedCountry.phoneCode}$phoneNumber");
  }
}
