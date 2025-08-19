import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMock {
  final Map<String, Map<String, dynamic>> _data = {};

  Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    final key = '$collection/$docId';
    _data[key] = data;
  }

  Future<Map<String, dynamic>?> getDocument(
      String collection, String docId) async {
    final key = '$collection/$docId';
    return _data[key];
  }

  Future<void> deleteDocument(String collection, String docId) async {
    final key = '$collection/$docId';
    _data.remove(key);
  }
}
