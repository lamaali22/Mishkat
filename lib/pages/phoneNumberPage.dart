import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneNumberPage extends StatefulWidget {
  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final TextEditingController phoneNumberController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _verifyPhoneNumber() async {
    String phoneNumber = phoneNumberController.text.trim();

    if (phoneNumber.isEmpty) {
      _showSnackbar('Please enter a phone number.');
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber)) {
      _showSnackbar('Please enter a valid 10-digit phone number.');
      return;
    }

    phoneNumber = '+91$phoneNumber'; // Adjust the country code as needed

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification completed successfully
          // Sign in the user with the credential
          await FirebaseAuth.instance.signInWithCredential(credential);
          _showSnackbar('User signed in automatically: ${FirebaseAuth.instance.currentUser?.uid}');
        },
        verificationFailed: (FirebaseAuthException e) {
          // Verification failed, handle the error
          _showSnackbar('Phone number verification failed: $e');
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Code has been sent to the provided phone number
          // Navigate to OTP verification page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout, handle the situation
          _showSnackbar('Auto-retrieval timeout. Verification ID: $verificationId');
        },
        timeout: Duration(seconds: 60), // Set the timeout for verification
      );
    } catch (e) {
      // Handle other errors
      _showSnackbar('Error during phone number verification: $e');
    }
  }

  void _showSnackbar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Phone Number Verification')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: Text('Verify Phone Number'),
            ),
          ],
        ),
      ),
    );
  }
}

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;

  OtpVerificationPage(this.verificationId);

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _verifyOTP() async {
    String otp = otpController.text.trim();

    if (otp.isEmpty) {
      _showSnackbar('Please enter the OTP.');
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _showSnackbar('User signed in with OTP: ${FirebaseAuth.instance.currentUser?.uid}');

      // Navigate to the next screen or perform necessary actions
    } catch (e) {
      // Handle OTP verification failure
      _showSnackbar('OTP verification failed: $e');
    }
  }

 void _showSnackbar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('OTP Verification')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter OTP'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
