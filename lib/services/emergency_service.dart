import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_model.dart';

class EmergencyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<EmergencyModel> createEmergency({
    required String userId,
    required double lat,
    required double lng,
  }) async {
    final docRef = _firestore.collection('emergencies').doc();

    final emergency = EmergencyModel(
      id: docRef.id,
      userId: userId,
      latitude: lat,
      longitude: lng,
      status: "CREATED",
      createdAt: DateTime.now(),
    );

    await docRef.set(emergency.toMap());
    return emergency;
  }

  Future<void> updateStatus(String emergencyId, String status) async {
    await _firestore
        .collection('emergencies')
        .doc(emergencyId)
        .update({'status': status});
  }
}
