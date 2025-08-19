import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bus/login_screen.dart';
import 'package:bus/registration_screen.dart';
import 'test_helpers.dart';

void main() {
  group('Critical Path Tests', () {
    setUpAll(() async {
      await initializeFirebase();
    });

    testWidgets('Login screen has email and password fields and login button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      expect(
          find.byType(TextFormField), findsNWidgets(2)); // Email and Password
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('Registration screen has required fields and register button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegistrationScreen()));

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Register'), findsOneWidget);
    });
  });
}
