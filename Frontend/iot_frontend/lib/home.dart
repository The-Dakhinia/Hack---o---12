import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iot_frontend/splashscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bottom_sheet.dart';
import 'map_test.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const LatLng _GooglePlx = LatLng(20.2961, 85.8245);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MapTest(latLongList: [],),
          Positioned(
            top: 30,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => _showPopupMenu(context),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              height: MediaQuery.of(context).size.height*0.4,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Colors.white,
              ),
              child: HomePage(),
            ),
          )
        ],
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(50, 50, 0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Set the border radius
      ),
      items: [
        PopupMenuItem(
          height: 40, // Set the height of the popup menu item
          child: ListTile(
            title: Text('Logout'),
            onTap: () => _handleLogout(context),
          ),
        ),
      ],
    );
  }

  void _handleLogout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.of(context).pop(); // Close the popup menu
    // Navigate to the login screen or any other initial screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => SplashScreen()));
  }

}