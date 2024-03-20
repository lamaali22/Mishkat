import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mishkat/pages/mapView.dart';
import 'package:mishkat/pages/otp_screen/otp.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  TextEditingController _phoneNumberController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  String _verificationId = '';
  bool isLoading = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 35,
              ),
              Center(child: Image.asset("assets/login.png")),
              const Center(
                child: Text(
                  'Welcome to Mishkat',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF09186C)),
                ),
              ),
              const Center(
                child: Text(
                  'Your indoor navigator in KSU',
                  style: TextStyle(color: Color(0xFF09186C)),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              const Text(
                'Phone number',
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF1F4FF),
                    hintText: "+966 5XXXXXXXX",
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF09186C))),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFF09186C)))),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all(const Color(0xFF09186C))),
                    onPressed: () {
                      if (_phoneNumberController.text.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          FirebaseAuth auth = FirebaseAuth.instance;
                          auth.verifyPhoneNumber(
                            phoneNumber: _phoneNumberController.text.trim(),
                            timeout: const Duration(seconds: 60),
                            verificationCompleted:
                                (AuthCredential credential) async {
                              Navigator.of(context).pop();
                              await auth.signInWithCredential(credential);
                            },
                            verificationFailed: (exception) {
                              print(exception);
                              setState(() {
                                isLoading = false;
                              });
                            },
                            codeSent:
                                (String verificationId, int? resendToken) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => OtpScreen(
                                          phone: _phoneNumberController.text
                                              .trim(),
                                          auth: auth,
                                          verificationId: verificationId)));
                            },
                            codeAutoRetrievalTimeout:
                                (String verificationId) {},
                          );
                        } on FirebaseAuthException catch (e) {
                          String message = "error Occurred";
                          if (e.code == 'weak-password') {
                            message = 'The password provided is too weak.';
                          } else if (e.code == 'email-already-in-use') {
                            message =
                                'The account already exists for that email.';
                          } else if (e.code == 'user-not-found') {
                            message = 'No user found for that email.';
                          } else if (e.code == 'wrong-password') {
                            message = 'Wrong password provided for that user.';
                          }
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(message),
                            backgroundColor: Theme.of(context).errorColor,
                          ));
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    child: const Text('Sign in'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(
                    child: Divider(
                      endIndent: 15,
                      thickness: 2,
                    ),
                  ),
                  Text("or"),
                  Expanded(
                    child: Divider(
                      thickness: 2,
                      indent: 15,
                    ),
                  ),
                ],
              ),
              Center(
                  child: TextButton(
                      onPressed: () {Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => MapScreen(title: "Map")));},
                      child: const Text(
                        "Continue as a guest",
                        style: TextStyle(
                            color: Color(0xFF09186C),
                            fontWeight: FontWeight.bold,
                            fontSize: 22),

                      )))
              /* TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signInWithPhoneNumber,
                child: const Text('Sign In with OTP'),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}