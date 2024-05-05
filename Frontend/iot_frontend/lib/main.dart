import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:iot_frontend/bottom_sheet.dart';
import 'package:iot_frontend/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color(0xFF137BBF), // Assign primary color here
        textTheme:
            GoogleFonts.rajdhaniTextTheme(), // Set primary font style here
      ),
      home: SplashScreen(),
    );
  }
}
