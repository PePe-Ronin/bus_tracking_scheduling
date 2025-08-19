import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';
import 'firestore_mock_setup.dart';

void main() {
  group('Driver Dashboard Backend Firestore Tests', () {
    late FirestoreMock firestoreMock;

    setUp(() {
      firestoreMock = FirestoreMock();
    });

    test('Save and retrieve driver data in FirestoreMock', () async {
      final driverData = {
        'driverID': 'DR123',
        'name': 'Jane Smith',
        'licenseNumber': 'LIC456',
      };

      await firestoreMock.setDocument('driver', 'testDriverDoc', driverData);

      final docData =
          await firestoreMock.getDocument('driver', 'testDriverDoc');

      expect(docData, isNotNull);
      expect(docData!['driverID'], driverData['driverID']);
      expect(docData['name'], driverData['name']);
      expect(docData['licenseNumber'], driverData['licenseNumber']);

      await firestoreMock.deleteDocument('driver', 'testDriverDoc');

      final deletedDoc =
          await firestoreMock.getDocument('driver', 'testDriverDoc');
      expect(deletedDoc, isNull);
    });
  });
}
