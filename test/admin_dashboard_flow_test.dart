import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bus/adminDashboard/adminDashboard.dart';
import 'test_helpers.dart';

void main() {
  group('Admin Dashboard UI/UX Flow Tests', () {
    setUpAll(() async {
      await initializeFirebase();
    });

    testWidgets('Navigate through Buses, Drivers, Stops screens',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
          home: MapAdmin(
              adminEmail: 'test@example.com', adminPassword: 'testpass')));

      // Verify initial screen
      expect(find.text('Admin Dashboard'), findsOneWidget);

      // Tap on Buses button and verify navigation
      final busesButton = find.text('Buses');
      expect(busesButton, findsOneWidget);
      await tester.tap(busesButton);
      await tester.pumpAndSettle();

      expect(find.text('Add New Bus'), findsOneWidget);

      // Go back to Admin Dashboard
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Tap on Drivers button and verify navigation
      final driversButton = find.text('Drivers');
      expect(driversButton, findsOneWidget);
      await tester.tap(driversButton);
      await tester.pumpAndSettle();

      expect(find.text('Add New Driver'), findsOneWidget);

      // Go back to Admin Dashboard
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Tap on Stops button and verify navigation
      final stopsButton = find.text('Stops');
      expect(stopsButton, findsOneWidget);
      await tester.tap(stopsButton);
      await tester.pumpAndSettle();

      expect(find.text('Add New Bus Stops'), findsOneWidget);
    });
  });
}
