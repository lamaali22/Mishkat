import 'dart:convert';
// import 'dart:js_util';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mishkat/models/member.dart';
import 'package:mishkat/pages/otpVerification.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isSignedIn = false;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  member? _member;
  member get userModel => _member!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: ((verificationId, forceResendingToken) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OtpVerificationPage(
                          verificationId: verificationId,
                        )));
          }),
          codeAutoRetrievalTimeout: (verification) {});
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
    }
  }

  //verify otp
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);
      User? user = (await _firebaseAuth.signInWithCredential(creds)).user!;
      if (user != null) {
        _uid = user.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
    }
  }

  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot =
        await _firebaseFirestore.collection("Member").doc(_uid).get();
    if (snapshot.exists) {
      print("USER EXISTS");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  void saveUserDataToFirebase({
    required BuildContext context,
    required member member,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      member.name = '';
      member.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
      member.listOfFavorites = [];
      member.listOfSavedClasses = [];

      _member = member;

      await _firebaseFirestore
          .collection("Member")
          .doc(_uid)
          .set(member.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      print(e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

// class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String verificationId;
  bool? isVerified;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // // STORING DATA LOCALLY
  // Future saveUserDataToSP() async {
  //   SharedPreferences s = await SharedPreferences.getInstance();
  //   await s.setString("member", jsonEncode(member.toMap()));
  // }

  // Future getDataFromSP() async {
  //   SharedPreferences s = await SharedPreferences.getInstance();
  //   String data = s.getString("member") ?? '';
  //   _member = member.fromMap(jsonDecode(data));

  //   notifyListeners();
  // }

  // Future<bool> checkIfUserExists(String phoneNumber) async {
  //   try {
  //     // Check if the user exists in Firestore based on phone number
  //     DocumentSnapshot userDoc =
  //         await _firestore.collection('Member').doc(phoneNumber).get();
  //     return userDoc.exists;
  //   } catch (e) {
  //     print('Error checking user existence: $e');
  //     return false;
  //   }
  // }

  // Future<bool> verifyOTP(
  //     String phoneNumber, String otp, String verificationId) async {
  //   try {
  //     // Verify OTP using Firebase Authentication
  //     PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //       verificationId: verificationId,
  //       smsCode: otp,
  //     );

  //     await _auth.signInWithCredential(credential);
  //     return true;
  //   } catch (e) {
  //     print('Error verifying OTP: $e');
  //     return false;
  //   }
  // }

  // Future<void> createUserEntry(String phoneNumber) async {
  //   try {
  //     // Create a new user entry in Firestore based on phone number
  //     await _firestore.collection('users').doc(phoneNumber).set({
  //       'phone_number': phoneNumber,
  //       // Add any additional user data as needed
  //     });
  //   } catch (e) {
  //     print('Error creating user entry: $e');
  //   }
  // }
}
