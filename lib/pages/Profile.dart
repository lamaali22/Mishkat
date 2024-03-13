import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mishkat/pages/EditProfile.dart';
import 'package:mishkat/pages/FavoritesScreen.dart';
import 'package:mishkat/pages/home_page.dart';
import 'package:mishkat/pages/viewSaved.dart';
import 'package:mishkat/services/ShareLocaion.dart';
import 'package:mishkat/widgets/MishkatNavigationBar.dart';
import 'package:mishkat/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileSettingsList(),
      ),
    );
  }
}

class ProfileSettingsList extends StatefulWidget {
  @override
  _ProfileSettingsList createState() => _ProfileSettingsList();
}

class _ProfileSettingsList extends State<ProfileSettingsList> {
  final Color iconAndTextColor = Color(0xFF09186C);
  final Color deleteIconAndTextColor = Color(0xFFBF360C);

  List<Map<String, dynamic>> itemList = [
    {"text": "Edit Profile", "icon": Icons.person_outline},
    {"text": "Favorites", "icon": Icons.favorite_border_outlined},
    {"text": "My Classes", "icon": Icons.pin_drop_outlined},
    {"text": "Signout", "icon": Icons.logout_outlined},
    {"text": "Delete Account", "icon": Icons.delete},
  ];

  Future<void> handleEditProfile() async {
    print("Edit profile");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(),
      ),
    );
  }

  Future<void> handleFavorites() async {
    print("favorites accessed from index 0 ( profile)");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritesScreen(
          index: 0,
        ),
      ),
    );
  }

  void handleMyClasses() async {
    print("My classes");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedPlacesPage(),
      ),
    );
  }

  void handleSignout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Colors.transparent,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16), // Add some spacing
            Text(
              "Are you sure you want to signout?",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF09186C),
              ),
            ),
          ],
        ),
        actions: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 229, 229, 232),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 83, 86, 105),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 249, 231, 231),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    } catch (e) {
                      print("Error signing out: $e");
                      // Handle error gracefully, show snackbar, etc.
                    }
                  },
                  child: Text(
                    "Sign Out",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 176, 63, 63),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void handleDeleteAccount(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color.fromARGB(255, 242, 243, 247),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: Colors.transparent,
          ),
        ),
        title: Text(
          "Confirm Delete Account",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF09186C),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16), // Add some spacing
            Text(
              "Are you sure you want to delete your account? This action cannot be undone.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF09186C),
              ),
            ),
          ],
        ),
        actions: [
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 229, 229, 232),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 83, 86, 105),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                padding: EdgeInsets.only(left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 249, 231, 231),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextButton(
                  onPressed: () async {
                    // Show a configuration message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Deleting account...'),
                      duration:
                          Duration(seconds: 1), // Adjust duration as needed
                    ));
                    try {
                      // Delete the user's account
                      await FirebaseAuth.instance.currentUser?.delete();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MyApp()), // Replace with appropriate route
                      );
                    } catch (e) {
                      print("Error deleting account: $e");
                      // Handle error gracefully, show snackbar, etc.
                    }
                  },
                  child: Text(
                    "Delete",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 176, 63, 63),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void handleItemSelected(Map<String, dynamic> selectedItem) {
    String text = selectedItem["text"];
    // IconData icon = selectedItem["icon"];

    switch (text) {
      case "Edit Profile":
        handleEditProfile();
        break;
      case "Favorites":
        handleFavorites();
        break;
      case "My Classes":
        handleMyClasses();
        break;
      case "Signout":
        handleSignout(context);
        break;
      case "Delete Account":
        handleDeleteAccount(context);
        break;
      default:
        print("Invalid selection");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    shareLoc.handleDynamicLinks(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: iconAndTextColor,
        title: Center(
          child: Text("Profile",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 24,
                color: Colors.white,
              )),
        ),

        toolbarHeight: 90, // Set the desired height here
        // Additional properties if needed
      ),
      body: ListView.builder(
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ListTile(
                trailing: (itemList[index]["text"] == "Edit Profile" ||
                        itemList[index]["text"] == "Favorites" ||
                        itemList[index]["text"] == "My Classes")
                    ? Icon(Icons.arrow_forward_ios_rounded,
                        color: iconAndTextColor)
                    : null,
                title: Text(
                  itemList[index]["text"],
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: itemList[index]["text"] == "Delete Account"
                        ? deleteIconAndTextColor
                        : iconAndTextColor,
                  ),
                  textAlign: TextAlign.left,
                ),
                leading: Icon(
                  itemList[index]["icon"],
                  color: itemList[index]["text"] == "Delete Account"
                      ? deleteIconAndTextColor
                      : iconAndTextColor,
                  size: 30,
                ),
                onTap: () {
                  handleItemSelected(itemList[index]);
                },
              ),
              if (index < 10) Divider(color: iconAndTextColor),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomNavigationBar(
        index: 0,
      ),
    );
  }
}
