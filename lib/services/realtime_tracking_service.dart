import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class RealtimeTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionStreamSubscription;

  // Request location permissions
  Future<bool> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  // Start tracking bus location
  Future<void> startTracking(String busId, String driverId) async {
    bool hasPermission = await requestLocationPermission();
    if (!hasPermission) return;

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _updateBusLocation(busId, driverId, position);
    });
  }

  // Update bus location in Firestore
  Future<void> _updateBusLocation(
      String busId, String driverId, Position position) async {
    await _firestore.collection('bus_locations').doc(busId).set({
      'busId': busId,
      'driverId': driverId,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'speed': position.speed,
      'heading': position.heading,
    }, SetOptions(merge: true));

    // Also update in buses collection
    await _firestore.collection('buses').doc(busId).update({
      'currentLocation': {
        'latitude': position.latitude,
        'longitude': position.longitude,
      },
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  // Get real-time bus location
  Stream<Map<String, dynamic>> getBusLocation(String busId) {
    return _firestore
        .collection('bus_locations')
        .doc(busId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
  }

  // Get all active buses locations
  Stream<List<Map<String, dynamic>>> getAllActiveBuses() {
    return _firestore
        .collection('bus_locations')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Stop tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
  }

  // Calculate ETA between two points
  Future<double> calculateETA(
      double startLat, double startLng, double endLat, double endLng) async {
    // This is a simplified calculation - in production, use Google Maps API
    const double earthRadius = 6371; // km
    final double dLat = (endLat - startLat) * (3.141592653589793 / 180);
    final double dLng = (endLng - startLng) * (3.141592653589793 / 180);
    final double a = (dLat * dLat) +
        (dLng * dLng) *
            (startLat * 3.141592653589793 / 180).cos() *
            (endLat * 3.141592653589793 / 180).cos();
    final double c = 2 * (a).atan2((1 - a).sqrt());
    final double distance = earthRadius * c;

    // Assume average speed of 30 km/h
    return distance / 30 * 60; // minutes
  }

  // Get bus route with stops
  Stream<List<Map<String, dynamic>>> getBusRoute(String routeId) {
    return _firestore
        .collection('routes')
        .doc(routeId)
        .collection('stops')
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
