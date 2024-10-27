import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:bus/welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Added a Scaffold to provide structure
      body: Column(
        children: [
          Container(
            child: Image.asset(
              'assets/bustii.png',
              height: 200,
              width: 200, // Set your desired height here
            ),
          ),
          Expanded(
            // Expands the SignInScreen to fill the remaining space
            child: SignInScreen(
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
              footerBuilder: (context, _) {
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Welcome to my youtube channel',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
