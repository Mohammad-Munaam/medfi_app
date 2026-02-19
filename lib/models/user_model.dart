import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String? email;
  final String role;
  final String? fcmToken;
  final bool active;
  final DateTime? shiftStart;
  final DateTime? shiftEnd;
  final List<String> assignedRequests;

  UserModel({
    required this.uid,
    this.email,
    this.role = 'user',
    this.fcmToken,
    this.active = false,
    this.shiftStart,
    this.shiftEnd,
    this.assignedRequests = const [],
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] as String?,
      role: data['role'] as String? ?? 'user',
      fcmToken: data['fcmToken'] as String?,
      active: data['active'] as bool? ?? false,
      shiftStart: (data['shiftStart'] as Timestamp?)?.toDate(),
      shiftEnd: (data['shiftEnd'] as Timestamp?)?.toDate(),
      assignedRequests: (data['assignedRequests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      if (email != null) 'email': email,
      'role': role,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'active': active,
      if (shiftStart != null) 'shiftStart': shiftStart,
      if (shiftEnd != null) 'shiftEnd': shiftEnd,
      'assignedRequests': assignedRequests,
    };
  }
}
