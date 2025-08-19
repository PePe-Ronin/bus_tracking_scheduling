import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String id;
  final String routeName;
  final String driverId;
  final String driverName;
  final String busId;
  final String busNumber;
  final List<StopModel> stops;
  final LocationModel startPoint;
  final LocationModel endPoint;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  RouteModel({
    required this.id,
    required this.routeName,
    required this.driverId,
    required this.driverName,
    required this.busId,
    required this.busNumber,
    required this.stops,
    required this.startPoint,
    required this.endPoint,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return RouteModel(
      id: doc.id,
      routeName: data['routeName'] ?? '',
      driverId: data['driverId'] ?? '',
      driverName: data['driverName'] ?? '',
      busId: data['busId'] ?? '',
      busNumber: data['busNumber'] ?? '',
      stops: (data['stops'] as List<dynamic>?)
              ?.map((stop) => StopModel.fromMap(stop))
              .toList() ??
          [],
      startPoint: LocationModel.fromMap(data['startPoint'] ?? {}),
      endPoint: LocationModel.fromMap(data['endPoint'] ?? {}),
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'routeName': routeName,
      'driverId': driverId,
      'driverName': driverName,
      'busId': busId,
      'busNumber': busNumber,
      'stops': stops.map((stop) => stop.toMap()).toList(),
      'startPoint': startPoint.toMap(),
      'endPoint': endPoint.toMap(),
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class StopModel {
  final String id;
  final String name;
  final LocationModel location;
  final int order;
  final String estimatedTime;

  StopModel({
    required this.id,
    required this.name,
    required this.location,
    required this.order,
    required this.estimatedTime,
  });

  factory StopModel.fromMap(Map<String, dynamic> map) {
    return StopModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: LocationModel.fromMap(map['location'] ?? {}),
      order: map['order'] ?? 0,
      estimatedTime: map['estimatedTime'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location.toMap(),
      'order': order,
      'estimatedTime': estimatedTime,
    };
  }
}

class LocationModel {
  final double latitude;
  final double longitude;

  LocationModel({
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
