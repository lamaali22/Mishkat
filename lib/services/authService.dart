import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
