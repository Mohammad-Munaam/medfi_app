import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final String vehicleType;
  final String vehicleNumber;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final String? profilePhoto;

  DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.latitude,
    required this.longitude,
    this.isAvailable = true,
    this.profilePhoto,
  });

  factory DriverModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Driver',
      phone: data['phone'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      vehicleType: data['vehicleType'] ?? 'Ambulance',
      vehicleNumber: data['vehicleNumber'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      isAvailable: data['isAvailable'] ?? false,
      profilePhoto: data['profilePhoto'],
    );
  }
}
