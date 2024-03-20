/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mishkat/pages/otp_page.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({Key? key}) : super(key: key);

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final phoneController = TextEditingController();
  bool showLoading = false;
  String verificationFailedMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Spacer(),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      hintText: "Phone Number",
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  SizedBox(
                    width: 290,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          showLoading = true;
                        });
                         print("on pressed");
                        _getNameFromFirestore();
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: phoneController.text,
                          verificationCompleted: (PhoneAuthCredential credential) {
                            print("verificationCompleted");
                          },
                          verificationFailed: (FirebaseAuthException e) {
                            setState(() {
                              showLoading = false;
                              verificationFailedMessage = e.message ?? "Error!";
                            });
                            print(e);
                             print("verificationFailed");

                          },
                          codeSent: (String verificationId, int? resendToken) {
                            setState(() {
                              showLoading = false;
                            });
                            print("codeSent");
                            

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OTPPage(isTimeOut2: false, verificationId: verificationId),
                              ),
                            );
                          },
                          timeout: const Duration(seconds: 10),
                          codeAutoRetrievalTimeout: (String verificationId) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OTPPage(isTimeOut2: true, verificationId: verificationId),
                              ),
                            );
                          },
                        );
                      },
                      child: Text('Sign in'),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF09186C),
                        onPrimary: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 290,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle the "Continue as guest" action
                      },
                      child: Text('Continue as guest'),
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF09186C),
                        onPrimary: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                  Text(verificationFailedMessage),
                  const Spacer(),
                ],
              ),
            ),
    );
  }
   Future<void> _getNameFromFirestore() async {
    print("innnnn");
    try {
      // Reference to the Firestore database
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Reference to the document containing the name
      DocumentSnapshot snapshot = await firestore.collection('Member').doc('g4molU09kwr4Xz3gX563').get();

      // Extract the name from the document data
      String name = snapshot.id;
      print("the ide ");
      print(name);

      // Update the state with the retrieved name
      setState(() {
       
      });
    } catch (error) {
      print('Error getting name from Firestore: $error');
    }
  }

}
*/