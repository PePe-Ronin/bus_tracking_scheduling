import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bus/adminDashboard/addbus.dart';
import 'package:bus/adminDashboard/adddriver.dart';
import 'package:bus/adminDashboard/addstops.dart';
import 'package:bus/adminDashboard/addschedules.dart';
import 'test_helpers.dart';

void main() {
  group('Admin Dashboard Feature Tests', () {
    setUpAll(() async {
      await initializeFirebase();
    });

    testWidgets('Add Bus screen has required fields and save button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
          home: addBus(
              adminEmail: 'test@example.com', adminPassword: 'password')));

      expect(find.text('Bus ID'), findsOneWidget);
      expect(find.text('Plate Number'), findsOneWidget);
      expect(find.text('Capacity'), findsOneWidget);
      expect(find.text('Bus Driver'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Add Driver screen has required fields and save button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddDriver()));

      expect(find.text('Add New Driver'), findsOneWidget);
      expect(find.text('Save Driver'), findsOneWidget);
    });

    testWidgets('Add Stops screen has required fields and save button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Addstops()));

      expect(find.text('Add New Bus Stops'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('Add Schedules screen has required fields and save button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Addschedules()));

      expect(find.text('Add New Bus Schedule'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });
}
