import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:bus/welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      providers: [
        EmailAuthProvider(), // Corrected usage
        // Add any other providers if needed
      ],
      actions: [
        AuthStateChangeAction<SignedIn>((context, state) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        }),
      ],
      headerBuilder: (context, constraints, _) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Welcome to My App',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        );
      },
      footerBuilder: (context, _) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Footer Text - Customize as needed',
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
