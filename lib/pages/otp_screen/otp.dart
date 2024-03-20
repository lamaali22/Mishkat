import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mishkat/pages/mapView.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.phone,
    required this.auth,
    required this.verificationId,
  });

  final phone;
  final auth;
  final verificationId;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  String _verificationId = '';

  TextEditingController _otpController = TextEditingController();

  Future<void> _signInWithPhoneNumber() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );

      await auth.signInWithCredential(credential);
      print('User signed in: ${auth.currentUser!.uid}');
    } catch (e) {
      print('Failed to sign in with phone number: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'OPT verification',
          style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF09186C)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          /* crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,*/
          children: [
            const SizedBox(
              height: 20,
            ),
            const Center(
              child: Text(
                'enter the code you received on your phone number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(
              height: 120,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: PinCodeTextField(
                appContext: context,
                autoFocus: true,
                keyboardType: TextInputType.number,
                length: 6,
                obscureText: false,
                animationType: AnimationType.scale,
                pinTheme: PinTheme(
                    shape: PinCodeFieldShape.underline,
                    borderRadius: BorderRadius.circular(15),
                    fieldHeight: 45,
                    fieldWidth: 45,
                    activeColor: const Color(0xFF09186C),
                    inactiveColor: Colors.grey,
                    inactiveFillColor: Colors.white,
                    activeFillColor: Colors.white,
                    selectedColor: const Color(0xFF09186C),
                    selectedFillColor: Colors.white),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onCompleted: (code) async {
                  AuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId, smsCode: code);
                  var result = await widget.auth.signInWithCredential(credential);
                  var user = result.user;
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .get()
                        .then((doc) async {
                      if (doc.exists == false) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                          'phone': widget.phone,
                        });
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => MapScreen(title: "Map")));
                      }
                    });
                  } catch (e) {
                    print(e);
                  }
                  if (user != null) {
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (_) => MapScreen(title: "Map",)));
                  } else {
                    print("Error");
                  }
                },
                onChanged: (value) {
                  log(value);
                },
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Didn’t you receive the OTP?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                Center(
                    child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Resend OTP",
                          style: TextStyle(
                              color: Color(0xFF09186C),
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ))),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xFF09186C))),
                    onPressed: () {},
                    child: const Text('Verify'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}