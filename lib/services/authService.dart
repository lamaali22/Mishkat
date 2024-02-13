import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String verificationId;
  bool? isVerified;

  Future<void> sendOTP(String? phoneNumber) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        isVerified = true;
      },
      verificationFailed: (FirebaseAuthException e) {
        isVerified = false;
        print('Verification Failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        print('Code Sent to $phoneNumber');
        print('Verification ID: $verificationId');
        this.verificationId = verificationId;
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print('Code Auto Retrieval Timeout');
      },
      timeout: Duration(seconds: 120),
    );
  }

  Future<void> updatePhoneNumber(String otp) async {
    try {
      // Get the currently signed-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Update the user's phone number
        // step 1 get credentials
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );

        // step 2 update using the obtained credentials
        await user.updatePhoneNumber(credential);

        // Phone number updated successfully
        print('Phone number updated successfully');
      } else {
        print('No user is currently signed in');
      }
    } catch (e) {
      // Handle errors
      print('Error updating phone number: $e');
    }
  }
}
