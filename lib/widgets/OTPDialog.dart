import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPDialog extends StatefulWidget {
  final Function(String) onOtpSubmitted;

  OTPDialog({required this.onOtpSubmitted});

  @override
  _OTPDialogState createState() => _OTPDialogState();
}

class _OTPDialogState extends State<OTPDialog> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          "Enter OTP",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Color(0xFF09186C),
          ),
        ),
      ),
      backgroundColor:
          Color.fromARGB(255, 242, 243, 247), // Set the background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0), // Set the border radius
        side: BorderSide(
          color: Colors.transparent, // Set border color
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Text(
              "Please enter OTP to update your phone number",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF09186C),
              ),
            ),
          ),
          PinCodeTextField(
            appContext: context,
            length: 6,
            onChanged: (value) {
              // Handle OTP changes
            },
            onCompleted: (value) {
              // Handle OTP when it's fully entered
              submitOTP(value);
            },
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.underline,
              inactiveColor: Color(0xFF09186C),
              activeColor: Color(0xFF09186C),
              // Set the text color for entered digits
            ),
            keyboardType: TextInputType.number,
            animationType: AnimationType.fade,
          ),
        ],
      ),
    );
  }

  void submitOTP(String otp) {
    // Perform action with the entered OTP
    print('Entered OTP: $otp');
    // Call the callback function with the entered OTP
    widget.onOtpSubmitted(otp);
    Navigator.of(context).pop(); // Close the dialog
  }

  String getOTP() {
    return otpController.text;
  }
}
