import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bus/driverDashboard/driverDashboard.dart';
import 'test_helpers.dart';

void main() {
  group('Driver Dashboard Tests', () {
    setUpAll(() async {
      await initializeFirebase();
    });

    testWidgets('Driver Dashboard renders and shows key UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          const MaterialApp(home: driverDashboard(email: 'test@example.com')));

      expect(find.text('Driver Dashboard'), findsOneWidget);
      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('Passengers'), findsOneWidget);
      expect(find.text('Number of Student'), findsOneWidget);
      expect(find.text('23/25'), findsOneWidget);
    });

    testWidgets('Drawer contains Account Settings and Logout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          const MaterialApp(home: driverDashboard(email: 'test@example.com')));

      // Open drawer
      ScaffoldState scaffoldState = tester.firstState(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Account Settings'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
