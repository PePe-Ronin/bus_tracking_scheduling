import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:bus/parentDashboard/parentDashboard.dart';
import 'test_helpers.dart';

void main() {
  group('Parent Dashboard Tests', () {
    setUpAll(() async {
      await initializeFirebase();
    });

    testWidgets('Parent Dashboard renders and shows key UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          MaterialApp(home: ParentDashboard(email: 'test@example.com')));

      expect(find.text('Parent Dashboard'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });
}
