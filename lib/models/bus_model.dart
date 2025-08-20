class BusModel {
  final String id;
  final String busNumber;
  final String driverId;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.driverId,
  });

  // Convert a BusModel into a Map. The keys must correspond to the names of the
  // fields in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'busNumber': busNumber,
      'driverId': driverId,
    };
  }

  // Create a BusModel from a Map.
  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      id: map['id'],
      busNumber: map['busNumber'],
      driverId: map['driverId'],
    );
  }
}
