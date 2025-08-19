import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bus/studentsDashboard/studentDashboard.dart';
import 'test_helpers.dart';

void main() {
  group('Students Dashboard Tests', () {
    setUpAll(() async {
      await initializeFirebase();
    });

    testWidgets('Students Dashboard renders and shows key UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: StudentDashboard(email: 'test@example.com')));

      expect(find.text('Student Dashboard'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
