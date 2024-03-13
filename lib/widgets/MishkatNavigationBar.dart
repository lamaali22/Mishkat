import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mishkat/pages/FavoritesScreen.dart';
import 'package:mishkat/pages/Profile.dart';
import 'package:mishkat/pages/mapView.dart';
import 'package:mishkat/pages/viewSaved.dart';

class CustomNavigationBar extends StatefulWidget {
  final int index;

  CustomNavigationBar({required this.index});

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState(index);
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int selectedIndex;

  _CustomNavigationBarState(this.selectedIndex);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, -10),
            blurRadius: 20,
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF09186C),
        unselectedItemColor: Color(0xFF707070),
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Use the Navigator to navigate to the appropriate page based on the selected index
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSettingsList(),
                ),
                (route) => false,
              );
              break;
            case 1:
              print("<MAP> on bar clicked");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => MapScreen(
                    center: LatLng(0, 0),
                  ),
                ),
                (route) => false,
              );
              break;
            case 2:
              print("favorites clicked accessed from index 2 (favorites)");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesScreen(
                    index: 2,
                  ),
                ),
                (route) => false,
              );
              break;
            case 3:
              print("my classes on bar clicked");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => SavedPlacesPage(),
                ),
                (route) => false, // This removes all the routes from the stack
              );
              break;
            // Add cases for other navigation items if needed
            default:
          }

          setState(() {
            selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded, size: 35),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pin_drop_outlined, size: 35),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded, size: 35),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline_rounded, size: 35),
            label: 'My Classes',
          ),
        ],
      ),
    );
  }
}
