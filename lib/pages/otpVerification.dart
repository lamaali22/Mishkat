// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
// import 'package:mishkat/pages/Profile.dart';
// import 'package:mishkat/services/authService.dart';

// class OtpVerificationPage extends StatefulWidget {
//   final String verificationId;
//   const OtpVerificationPage({super.key, required this.verificationId});

//   @override
//   State<OtpVerificationPage> createState() => _OtpVerificationPageState();
// }

// class _OtpVerificationPageState extends State<OtpVerificationPage> {
//   String? otpCode;
//   @override
//   Widget build(BuildContext context) {
//     final isLoading = Provider.of<AuthService>(context, listen: true).isLoading;
//     return Scaffold(
//       body: SafeArea(
//         child: isLoading == true
//             ? const Center(
//                 child: CircularProgressIndicator(
//                   color: Color(0xFF09186C),
//                 ),
//               )
//             : Center(
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
//                   child: Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.topLeft,
//                         child: GestureDetector(
//                           onTap: () => Navigator.of(context).pop(),
//                           child: const Icon(Icons.arrow_back),
//                         ),
//                       ),
//                       Container(
//                         width: 200,
//                         height: 200,
//                         padding: const EdgeInsets.all(20.0),
//                         child: Image.asset(
//                           "assets/logo.png",
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Verification",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       const Text(
//                         "Enter the OTP send to your phone number",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.black38,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 20),
//                       Pinput(
//                         length: 6,
//                         showCursor: true,
//                         defaultPinTheme: PinTheme(
//                           width: 60,
//                           height: 60,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: Color(0xFF09186C),
//                             ),
//                           ),
//                           textStyle: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         onCompleted: (value) {
//                           setState(() {
//                             otpCode = value;
//                           });
//                         },
//                       ),
//                       const SizedBox(height: 25),
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width,
//                         height: 50,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             if (otpCode != null) {
//                               verifyOtp(context, otpCode!);
//                             } else {
//                               _showSnackbar('Enter 6-Digit code');
//                             }
//                           },
//                           child: Text("Verify"),
//                           style: ElevatedButton.styleFrom(
//                             primary: Color(0xFF09186C),
//                             onPrimary: Colors.white,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Didn't receive any code?",
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black38,
//                         ),
//                       ),
//                       const SizedBox(height: 15),
//                       const Text(
//                         "Resend New Code",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF09186C),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   void verifyOtp(BuildContext context, String userOtp) {
//     final as = Provider.of<AuthService>(context, listen: false);
//     as.verifyOtp(
//       context: context,
//       verificationId: widget.verificationId,
//       userOtp: userOtp,
//       onSuccess: () {
//         //check if user exist
//         as.checkExistingUser().then((value) async {
//           if (value == true) {
//           } else {
//             Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => ProfileSettingsList()),
//                 (route) => false);
//           }
//         });
//       },
//     );
//   }
// }

// // class OtpVerificationPage extends StatelessWidget {
// //   final String phoneNumber;
// //   final bool userExists;

// //   OtpVerificationPage(this.phoneNumber, this.userExists);

// //   final TextEditingController otpController = TextEditingController();

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('OTP Verification')),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             TextField(
// //               controller: otpController,
// //               keyboardType: TextInputType.number,
// //               decoration: InputDecoration(labelText: 'Enter OTP'),
// //             ),
// //             SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: () async {
// //                 // Verifying OTP
// //                 String otp = otpController.text;

// //                 // Get the verificationId passed from PhoneNumberPage
// //                 String verificationId =
// //                     ModalRoute.of(context)!.settings.arguments as String;
// //                 print('in otp');
// //                 bool isVerified = await AuthService()
// //                     .verifyOTP(phoneNumber, otp, verificationId);

// //                 // Checking if the user exists in Firestore
// //                 bool userExistsAfterVerification =
// //                     await AuthService().checkIfUserExists(phoneNumber);

// //                 if (isVerified) {
// //                   if (userExistsAfterVerification) {
// //                     // User exists, navigate to home page
// //                     Navigator.pushReplacement(
// //                       context,
// //                       MaterialPageRoute(builder: (context) => HomePage()),
// //                     );
// //                   } else {
// //                     // User doesn't exist, create new user entry
// //                     await AuthService().createUserEntry(phoneNumber);
// //                     // Navigate to home page
// //                     Navigator.pushReplacement(
// //                       context,
// //                       MaterialPageRoute(builder: (context) => HomePage()),
// //                     );
// //                   }
// //                 } else {
// //                   // Handle OTP verification failure
// //                   // You may want to show an error message to the user
// //                 }
// //               },
// //               child: Text('Verify OTP'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
