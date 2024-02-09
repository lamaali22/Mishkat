import 'package:flutter/material.dart';
import 'package:mishkat/pages/home_page.dart';
import 'package:mishkat/services/authService.dart';


class OtpVerificationPage extends StatelessWidget {
  final String phoneNumber;
  final bool userExists;

  OtpVerificationPage(this.phoneNumber, this.userExists);

  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              onPressed: () async {
                // Verifying OTP
                String otp = otpController.text;

                // Get the verificationId passed from PhoneNumberPage
                String verificationId = ModalRoute.of(context)!.settings.arguments as String;
print('in otp');
                bool isVerified = await AuthService().verifyOTP(phoneNumber, otp, verificationId);

                // Checking if the user exists in Firestore
                bool userExistsAfterVerification = await AuthService().checkIfUserExists(phoneNumber);

                if (isVerified) {
                  if (userExistsAfterVerification) {
                    // User exists, navigate to home page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } else {
                    // User doesn't exist, create new user entry
                    await AuthService().createUserEntry(phoneNumber);
                    // Navigate to home page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  }
                } else {
                  // Handle OTP verification failure
                  // You may want to show an error message to the user
                }
              },
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
