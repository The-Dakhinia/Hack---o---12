import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool showContainer = false;
  bool showScreen = false;
  bool isLoading = false; // Add isLoading state to track whether Google sign-in is in progress


  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      setState(() {
        isLoading = true; // Show circular progress indicator when Google sign-in starts
      });

      // Trigger Google sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        // Obtain the authentication credentials
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        // Sign in to Firebase with the obtained credentials
        final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = userCredential.user;

        // Save user login status using shared preferences
        if (user != null) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
        }
      }
    } catch (e) {
      // Handle sign-in errors
      print("Error signing in with Google: $e");
    } finally {
      setState(() {
        isLoading = false; // Hide circular progress indicator when Google sign-in completes
      });
    }
  }


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      setState(() {
        showContainer = true;
      });
    });
    Timer(Duration(seconds: 1), () {
      setState(() {
        showScreen = true;
      });
    });
    // Check if the user is already logged in
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo and Name
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  opacity: showScreen ? 1.0 : 0.0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3, // Adjust the height as needed
                    width: MediaQuery.of(context).size.width * 0.35, // Adjust the width as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        Image.asset(
                          'assets/logo.png',
                        ),
                        Positioned(
                          top: 220,
                          child: Center(
                            child: AnimatedOpacity(
                              duration: Duration(seconds: 1),
                              opacity: showScreen ? 1.0 : 0.0,
                              child: Text(
                                'ParkEasy',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF137BBF),
                                    letterSpacing: 0.6
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Signup with Google button or Circular progress indicator
          AnimatedPositioned(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
            bottom: showContainer ? 60 : -200,
            child: isLoading
                ? Container(
              padding: EdgeInsets.symmetric(horizontal: 65),
              height: 60,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: Center( // Center the CircularProgressIndicator horizontally
                child: CircularProgressIndicator(),
              ),
            )
                : Container(
              padding: EdgeInsets.symmetric(horizontal: 65),
              height: 60,
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () => _handleGoogleSignIn(context),
                child: Card(
                  color: Color(0xFF137BBF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Image.asset(
                              "assets/google.png",
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Text(
                          "Signup with Google",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
