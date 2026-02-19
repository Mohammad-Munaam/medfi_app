import 'package:cloud_firestore/cloud_firestore.dart';

class AmbulanceRequest {
  final String id;
  final String userId;
  final String? name;
  final String? phone;
  final String? details;
  final GeoPoint? location;
  final String status;
  final String driverName;
  final String ambulanceNumber;
  final String? assignedOperatorId;
  final DateTime? assignedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AmbulanceRequest({
    required this.id,
    required this.userId,
    this.name,
    this.phone,
    this.details,
    this.location,
    required this.status,
    this.driverName = '',
    this.ambulanceNumber = '',
    this.assignedOperatorId,
    this.assignedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AmbulanceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AmbulanceRequest(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String?,
      phone: data['phone'] as String?,
      details: data['details'] as String?,
      location: data['location'] as GeoPoint?,
      status: data['status'] as String? ?? 'requested',
      driverName: data['driverName'] as String? ?? '',
      ambulanceNumber: data['ambulanceNumber'] as String? ?? '',
      assignedOperatorId: data['assignedOperatorId'] as String?,
      assignedAt: (data['assignedAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (details != null) 'details': details,
      if (location != null) 'location': location,
      'status': status,
      'driverName': driverName,
      'ambulanceNumber': ambulanceNumber,
      if (assignedOperatorId != null) 'assignedOperatorId': assignedOperatorId,
      if (assignedAt != null) 'assignedAt': assignedAt,
    };
  }

  /// Returns the next valid status or null if terminal
  String? get nextStatus {
    switch (status) {
      case 'requested':
        return 'on_the_way';
      case 'on_the_way':
        return 'arrived';
      case 'arrived':
        return 'completed';
      default:
        return null;
    }
  }

  /// Human-readable status label
  String get statusLabel {
    switch (status) {
      case 'requested':
        return 'Requested';
      case 'on_the_way':
        return 'On The Way';
      case 'arrived':
        return 'Arrived';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}
