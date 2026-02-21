import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String? name;
  final String? photoUrl;
  final String role;
  final String? fcmToken;
  final bool active;
  final DateTime? shiftStart;
  final DateTime? shiftEnd;
  final List<String> assignedRequests;

  // Medical Info
  final String? bloodType;
  final double? height;
  final double? weight;
  final bool? organDonorStatus;

  // Personal Info
  final String? dob;
  final String? gender;
  final String? primaryEmergencyNumber;
  final String? secondaryEmergencyNumber;

  UserModel({
    required this.uid,
    this.email,
    this.name,
    this.photoUrl,
    this.role = 'user',
    this.fcmToken,
    this.active = false,
    this.shiftStart,
    this.shiftEnd,
    this.assignedRequests = const [],
    this.bloodType,
    this.height,
    this.weight,
    this.organDonorStatus,
    this.dob,
    this.gender,
    this.primaryEmergencyNumber,
    this.secondaryEmergencyNumber,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      name: data['name'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? 'user',
      fcmToken: data['fcmToken'] as String?,
      active: data['active'] as bool? ?? false,
      shiftStart: (data['shiftStart'] as Timestamp?)?.toDate(),
      shiftEnd: (data['shiftEnd'] as Timestamp?)?.toDate(),
      assignedRequests: (data['assignedRequests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      bloodType: data['bloodType'] as String?,
      height: (data['height'] as num?)?.toDouble(),
      weight: (data['weight'] as num?)?.toDouble(),
      organDonorStatus: data['organDonorStatus'] as bool?,
      dob: data['dob'] as String?,
      gender: data['gender'] as String?,
      primaryEmergencyNumber: data['primaryEmergencyNumber'] as String?,
      secondaryEmergencyNumber: data['secondaryEmergencyNumber'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'active': active,
      if (shiftStart != null) 'shiftStart': shiftStart,
      if (shiftEnd != null) 'shiftEnd': shiftEnd,
      'assignedRequests': assignedRequests,
      if (bloodType != null) 'bloodType': bloodType,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (organDonorStatus != null) 'organDonorStatus': organDonorStatus,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      if (primaryEmergencyNumber != null)
        'primaryEmergencyNumber': primaryEmergencyNumber,
      if (secondaryEmergencyNumber != null)
        'secondaryEmergencyNumber': secondaryEmergencyNumber,
    };
  }
}
