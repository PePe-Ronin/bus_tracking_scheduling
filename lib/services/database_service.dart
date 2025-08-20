import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';
import '../models/route_model.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Bus operations
  Future<void> addBus(BusModel bus) async {
    await _firestore.collection('buses').doc(bus.id).set(bus.toMap());
  }

  Future<void> updateBus(BusModel bus) async {
    await _firestore.collection('buses').doc(bus.id).update(bus.toMap());
  }

  Future<void> deleteBus(String busId) async {
    await _firestore.collection('buses').doc(busId).delete();
  }

  Stream<List<BusModel>> getBuses() {
    return _firestore.collection('buses').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => BusModel.fromFirestore(doc.data()))
        .toList());
  }

  // Route operations
  Future<void> addRoute(RouteModel route) async {
    await _firestore.collection('routes').doc(route.id).set(route.toMap());
  }

  Future<void> updateRoute(RouteModel route) async {
    await _firestore.collection('routes').doc(route.id).update(route.toMap());
  }

  Future<void> deleteRoute(String routeId) async {
    await _firestore.collection('routes').doc(routeId).delete();
  }

  Stream<List<RouteModel>> getRoutes() {
    return _firestore.collection('routes').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => RouteModel.fromFirestore(doc.data()))
            .toList());
  }

  // User operations
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).update(user.toMap());
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) => snapshot
        .docs
        .map((doc) => UserModel.fromFirestore(doc.data()))
        .toList());
  }

  // Bus location operations
  Future<void> updateBusLocation(
      String busId, Map<String, dynamic> location) async {
    await _firestore.collection('bus_locations').doc(busId).set(location);
  }

  Stream<Map<String, dynamic>> getBusLocation(String busId) {
    return _firestore
        .collection('bus_locations')
        .doc(busId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  // Route operations
  Future<void> addRouteStop(String routeId, Map<String, dynamic> stop) async {
    await _firestore
        .collection('routes')
        .doc(routeId)
        .collection('stops')
        .add(stop);
  }

  Stream<List<Map<String, dynamic>>> getRouteStops(String routeId) {
    return _firestore
        .collection('routes')
        .doc(routeId)
        .collection('stops')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Schedule operations
  Future<void> addSchedule(Map<String, dynamic> schedule) async {
    await _firestore.collection('schedules').add(schedule);
  }

  Stream<List<Map<String, dynamic>>> getSchedules() {
    return _firestore
        .collection('schedules')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Attendance operations
  Future<void> markAttendance(
      String studentId, String busId, String date) async {
    await _firestore.collection('attendance').add({
      'studentId': studentId,
      'busId': busId,
      'date': date,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getAttendance(String studentId) {
    return _firestore
        .collection('attendance')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Notification operations
  Future<void> sendNotification(
      String userId, String title, String body) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Emergency operations
  Future<void> sendEmergencyAlert(String userId, String message) async {
    await _firestore.collection('emergency_alerts').add({
      'userId': userId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getEmergencyAlerts() {
    return _firestore
        .collection('emergency_alerts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
