import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String verificationId;
  bool? isVerified;

Future<bool> checkIfUserExists(String phoneNumber) async {
    try {
      // Check if the user exists in Firestore based on phone number
      DocumentSnapshot userDoc = await _firestore.collection('Member').doc(phoneNumber).get();
      return userDoc.exists;
    } catch (e) {
      print('Error checking user existence: $e');
      return false;
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otp, String verificationId) async {
    try {
      // Verify OTP using Firebase Authentication
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  Future<void> createUserEntry(String phoneNumber) async {
    try {
      // Create a new user entry in Firestore based on phone number
      await _firestore.collection('users').doc(phoneNumber).set({
        'phone_number': phoneNumber,
        // Add any additional user data as needed
      });
    } catch (e) {
      print('Error creating user entry: $e');
    }
  }
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
