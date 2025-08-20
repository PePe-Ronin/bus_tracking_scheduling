class UserModel {
  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String phone;
  final String? profileImage;
  final Map<String, dynamic>? additionalData;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.profileImage,
    this.additionalData,
  });

  // Convert a UserModel into a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'profileImage': profileImage,
      'additionalData': additionalData,
    };
  }

  // Create a UserModel from a Map.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phone: map['phone'] ?? '',
      profileImage: map['profileImage'],
      additionalData: map['additionalData'],
    );
  }

  // Create a UserModel from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> map) {
    return UserModel.fromMap(map);
  }
}
