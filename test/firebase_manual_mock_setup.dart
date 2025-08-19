import 'package:firebase_auth/firebase_auth.dart';

class MockUser implements User {
  @override
  String get uid => 'mock_uid';

  // Implement only the methods and properties used in your tests
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockFirebaseAuth implements FirebaseAuth {
  @override
  User? get currentUser => MockUser();

  // Implement only the methods and properties used in your tests
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
