import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';
import 'firestore_mock_setup.dart';

void main() {
  group('Admin Dashboard Backend Firestore Tests', () {
    late FirestoreMock firestoreMock;

    setUp(() {
      firestoreMock = FirestoreMock();
    });

    test('Add Bus data is saved correctly to FirestoreMock', () async {
      // Sample bus data
      final busData = {
        'busID': 'BUS123',
        'plateNumber': 'ABC-123',
        'capacity': '40',
        'driver': 'John Doe',
      };

      // Save bus data to FirestoreMock
      await firestoreMock.setDocument('bus', 'testBusDoc', busData);

      // Retrieve the saved document
      final docData = await firestoreMock.getDocument('bus', 'testBusDoc');

      expect(docData, isNotNull);
      expect(docData!['busID'], busData['busID']);
      expect(docData['plateNumber'], busData['plateNumber']);
      expect(docData['capacity'], busData['capacity']);
      expect(docData['driver'], busData['driver']);

      // Clean up test document
      await firestoreMock.deleteDocument('bus', 'testBusDoc');

      final deletedDoc = await firestoreMock.getDocument('bus', 'testBusDoc');
      expect(deletedDoc, isNull);
    });
  });
}
