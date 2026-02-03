class EmergencyModel {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;
  final String? ambulanceId;

  EmergencyModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.ambulanceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'ambulanceId': ambulanceId,
    };
  }

  factory EmergencyModel.fromMap(Map<String, dynamic> map) {
    return EmergencyModel(
      id: map['id'],
      userId: map['userId'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
      ambulanceId: map['ambulanceId'],
    );
  }
}
