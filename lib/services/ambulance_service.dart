import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AmbulanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> requestAmbulance({
    required String issue,
    required String location,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    await _firestore.collection('ambulance_requests').add({
      'userId': user.uid,
      'issue': issue,
      'location': location,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
