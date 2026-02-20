import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

Future<void> seedDummyDrivers() async {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final driversRef = db.collection('drivers');

  final List<Map<String, dynamic>> dummyDrivers = [
    {
      'name': 'John Doe',
      'phone': '+1234567890',
      'rating': 4.8,
      'vehicleType': 'Basic Ambulance',
      'vehicleNumber': 'KA-01-AB-1234',
      'latitude': 37.4225,
      'longitude': -122.085,
      'isAvailable': true,
      'profilePhoto': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Jane Smith',
      'phone': '+1987654321',
      'rating': 4.9,
      'vehicleType': 'ICU Ambulance',
      'vehicleNumber': 'KA-02-CD-5678',
      'latitude': 37.421,
      'longitude': -122.083,
      'isAvailable': true,
      'profilePhoto': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Mike Johnson',
      'phone': '+1122334455',
      'rating': 4.5,
      'vehicleType': 'Advanced Life Support',
      'vehicleNumber': 'KA-03-EF-9012',
      'latitude': 37.423,
      'longitude': -122.086,
      'isAvailable': true,
      'profilePhoto': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Sarah Wilson',
      'phone': '+1556677889',
      'rating': 5.0,
      'vehicleType': 'Rapid Response',
      'vehicleNumber': 'KA-04-GH-3456',
      'latitude': 37.420,
      'longitude': -122.082,
      'isAvailable': true,
      'profilePhoto': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'Robert Brown',
      'phone': '+1998877665',
      'rating': 4.7,
      'vehicleType': 'Patient Transport',
      'vehicleNumber': 'KA-05-IJ-7890',
      'latitude': 37.424,
      'longitude': -122.081,
      'isAvailable': true,
      'profilePhoto': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
  ];

  for (var driver in dummyDrivers) {
    await driversRef.add(driver);
    debugPrint("✅ Added driver: ${driver['name']}");
  }
}
