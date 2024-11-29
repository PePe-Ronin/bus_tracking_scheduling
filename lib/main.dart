import 'package:bus/adminDashboard/drivers.dart';
import 'package:bus/adminDashboard/map.dart';
import 'package:bus/login_screen.dart';
import 'package:bus/registration_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:bus/adminDashboard/addbussched.dart';
import 'package:bus/adminDashboard/adddriver.dart';
import 'package:bus/adminDashboard/viewstudentregistration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:
          'School Bus Scheduling and Tracking Mobile App for Sibugay Technical Institute Incorporated',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DriverScreen(),
    );
  }
}
