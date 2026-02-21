import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String id;
  final String name;
  final String? photoUrl;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;
  final double rating;
  final double currentLat;
  final double currentLng;
  final bool isAvailable;

  DriverModel({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.rating,
    required this.currentLat,
    required this.currentLng,
    this.isAvailable = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'rating': rating,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'isAvailable': isAvailable,
    };
  }

  factory DriverModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverModel.fromMap(data, doc.id);
  }

  factory DriverModel.fromMap(Map<String, dynamic> map, String docId) {
    return DriverModel(
      id: docId,
      name: map['name'] ?? 'Unknown',
      photoUrl: map['photoUrl'] ?? map['profilePhoto'],
      phone: map['phone'] ?? '',
      vehicleType: map['vehicleType'] ?? 'Basic Ambulance',
      vehicleNumber: map['vehicleNumber'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      currentLat: (map['currentLat'] as num?)?.toDouble() ??
          (map['latitude'] as num?)?.toDouble() ??
          0.0,
      currentLng: (map['currentLng'] as num?)?.toDouble() ??
          (map['longitude'] as num?)?.toDouble() ??
          0.0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }
}
