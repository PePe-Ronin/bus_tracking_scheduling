import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  final String id;
  final String busNumber;
  final String driverId;
  final String driverName;
  final int capacity;
  final String status;
  final String routeId;
  final String routeName;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.driverId,
    required this.driverName,
    required this.capacity,
    required this.status,
    required this.routeId,
    required this.routeName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BusModel(
      id: doc.id,
      busNumber: data['busNumber'] ?? '',
      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? '',
      capacity: data['capacity'] ?? 0,
      status: data['status'] ?? 'active',
      routeId: data['routeId'] ?? '',
      routeName: data['routeName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'busNumber': busNumber,
      'driverId': driverId,
      'driverName': driverName,
      'capacity': capacity,
      'status': status,
      'routeId': routeId,
      'routeName': routeName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
