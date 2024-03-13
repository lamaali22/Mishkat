import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat/services/Validators.dart';
import 'package:mishkat/services/authService.dart';
import 'package:mishkat/widgets/MishkatNavigationBar.dart';
import 'package:mishkat/widgets/OTPDialog.dart';
import 'package:mishkat/widgets/Messages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: EditProfile(),
      ),
    );
  }
}

class EditProfile extends StatefulWidget {
  @override
  _EditProfile createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  final nameController = TextEditingController();
  final phoneNumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _db = FirebaseFirestore.instance;

  FocusNode memberNameFocus = FocusNode();
  FocusNode phoneNumFocus = FocusNode();
  late String initialName;
  late String initialPhoneNum;
  bool isChanged = false;

  @override
  void dispose() {
    memberNameFocus.dispose();
    phoneNumFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Fetch user data and populate controllers
    initUserData();
    memberNameFocus = FocusNode();
    phoneNumFocus = FocusNode();

    // Add listeners to focus nodes
    memberNameFocus.addListener(() {
      if (!memberNameFocus.hasFocus) {
        _formKey.currentState?.validate();

        if (_formKey.currentState?.validate() ?? false) {
          if (nameController.text != initialName) {
            setState(() {
              isChanged = true;
            });
          } else if (phoneNumController.text == initialPhoneNum) {
            setState(() {
              isChanged = false;
            });
            print("nothing changed");
          }
        }
      } else
        setState(() {
          isChanged = false;
        });
    });

    phoneNumFocus.addListener(() {
      if (!phoneNumFocus.hasFocus) {
        _formKey.currentState?.validate();

        if (_formKey.currentState?.validate() ?? false) {
          if (phoneNumController.text != initialPhoneNum) {
            setState(() {
              isChanged = true;
            });
          } else if (nameController.text == initialName) {
            setState(() {
              isChanged = false;
            });
          }
        }
      } else
        setState(() {
          isChanged = false;
        });
    });
  }

  Future<void> initUserData() async {
    await fetchUserData();

    initialName = nameController.text;
    initialPhoneNum = phoneNumController.text;
  }

  String? phoneNumber = "";

  Future<void> fetchUserData() async {
    // correct code for fetching
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Update the phoneNumber variable with the current user's phone Number
      phoneNumber = user.phoneNumber!;
      print('User email: $phoneNumber');

      QuerySnapshot querySnapshot = await _db
          .collection('Member')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;

        setState(() {
          nameController.text = userData['name'] ?? '';
          phoneNumController.text = userData['phoneNumber'] ?? '';
        });
      }
    }
  }

  AuthService authService = AuthService();
  Future<void> update() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print('Current user phone before update: ${user.phoneNumber}');
    } else {
      print('No current user found');
      return;
    }

    // if the phone number has been changed
    if (user.phoneNumber != phoneNumController.text.trim()) {
      //send otp and verify
      authService.sendOTP(phoneNumController.text);

      //after sending an otp
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return OTPDialog(
            onOtpSubmitted: (String otp) async {
              authService.updatePhoneNumber(otp);
              // Handle the entered OTP value here in the calling page
              print('Received OTP in calling page: $otp');
            },
          );
        },
      );
    }

// Now update other user data in Firestore
    QuerySnapshot querySnapshot = await _db
        .collection('Member')
        .where('phoneNumber', isEqualTo: user.phoneNumber)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      String userId = querySnapshot.docs.first.id;

      await _db.collection('Member').doc(userId).update({
        'name': nameController.text.trim(),
        'phoneNumber': phoneNumController.text.trim(),
      });

      initialName = nameController.text;
      initialPhoneNum = phoneNumController.text;

      showUpdateSuccessMessage(context);
    }
  }

  List<String> phones = [];
  Future<void> fetchPhonesAsync() async {
    final QuerySnapshot querySnapshot1 = await _db.collection('Member').get();
    final List<QueryDocumentSnapshot> documents2 = querySnapshot1.docs;

    for (QueryDocumentSnapshot doc in documents2) {
      final data = doc.data() as Map<String, dynamic>; // Access data as a Map
      if (data.containsKey('phoneNumber')) {
        final phoneNumber = data['phoneNumber'] as String;
        phones.add(phoneNumber);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Disable the default back button
          backgroundColor: Color(0xFF09186C),
          title: Text(
            "Edit Profile",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 24,
              color: Colors.white,
            ),
          ),

          toolbarHeight: 90,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              // Add your logic to handle the back action
              Navigator.of(context).pop();
            },
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(
          index: 0,
        ),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 70,
                  ),
                  Text(
                    "Name",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF09186C),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    focusNode: memberNameFocus,
                    decoration: InputDecoration(
                      fillColor: Color(0xFFF1F4FF),
                      filled: true,
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    onChanged: (value) {},
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Field is empty';
                      } else if (value.length > 30)
                        return 'Please enter a valid name';
                      return null;
                    },
                    onEditingComplete: () {},
                  ),
                  SizedBox(height: 35),
                  Text(
                    "Phone Number",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF09186C),
                    ),
                  ),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: phoneNumController,
                    focusNode: phoneNumFocus,
                    decoration: InputDecoration(
                      prefixText: "+966 | ",
                      fillColor: Color(0xFFF1F4FF),
                      filled: true,
                      contentPadding: EdgeInsets.all(10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    onChanged: (value) {
                      if (value != initialPhoneNum) isChanged = true;
                    },
                    onTap: () {
                      fetchPhonesAsync();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field is empty';
                      } else if (!Validator().validatePhoneNum(value))
                        return 'Please enter a correct phone number 05x xxxx xxx';
                      else if (!Validator()
                          .isNumericUsingRegularExpression(value))
                        return 'Please enter numbers only';
                      else if (phones.contains(value.toString()) &&
                          value != initialPhoneNum)
                        return 'This number has been used';
                      else
                        return null;
                    },
                  ),
                  SizedBox(
                    height: 150,
                  ),
                  ElevatedButton(
                    onPressed: isChanged
                        ? () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Add your logic when the button is pressed and form is valid
                              update();
                            }
                          }
                        : null, // Set onPressed to null when isChanged is false
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF09186C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Colors.black.withOpacity(0.2),
                      elevation: 5,
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        "Save Changes",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              )),
        )));
  }
}
