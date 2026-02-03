class AmbulanceRequest {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String location;
  final String status;

  AmbulanceRequest({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.location,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'location': location,
      'status': status,
    };
  }
}
