import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save FCM Token
  Future<void> saveUserToken(String userId, String token) async {
    try {
      await _db.collection('users').doc(userId).set({
        'fcmToken': token,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // Removed timeout for better reliability
      debugPrint("✅ FCM Token saved to Firestore");
    } catch (e) {
      debugPrint("❌ Error saving FCM token: $e");
    }
  }

  /// Save default user role on registration (merge to preserve other fields)
  Future<void> saveUserRole(String userId, String email) async {
    try {
      await _db.collection('users').doc(userId).set({
        'email': email,
        'role': 'user',
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)).timeout(const Duration(seconds: 10));
      debugPrint("✅ User role saved to Firestore");
    } catch (e) {
      debugPrint("❌ Error saving user role: $e");
    }
  }

  // Create Ambulance Request
  Future<String?> createAmbulanceRequest({
    required String userId,
    required String details,
    required double lat,
    required double lng,
  }) async {
    try {
      DocumentReference ref = await _db.collection('ambulance_requests').add({
        'userId': userId,
        'details': details,
        'location': GeoPoint(lat, lng),
        'status': 'requested',
        'driverName': '',
        'ambulanceNumber': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
      debugPrint("✅ Ambulance Request Created: ${ref.id}");
      return ref.id;
    } catch (e) {
      debugPrint("❌ Error creating request: $e");
      return null;
    }
  }

  // Update Driver Location (Raw Helper)
  Future<void> updateDriverLocation(
      String requestId, double lat, double lng, double heading) async {
    try {
      await _db.collection('ambulance_requests').doc(requestId).update({
        'driverLocation': {
          'latitude': lat,
          'longitude': lng,
          'heading': heading,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
    } catch (e) {
      debugPrint("❌ Error updating driver location: $e");
    }
  }

  // Update Request Status
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _db.collection('ambulance_requests').doc(requestId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }).timeout(const Duration(seconds: 10));
      debugPrint("✅ Request status updated to: $status");
    } catch (e) {
      debugPrint("❌ Error updating status: $e");
    }
  }

  // Stream Request Status
  Stream<DocumentSnapshot> streamRequestStatus(String requestId) {
    return _db.collection('ambulance_requests').doc(requestId).snapshots();
  }

  // --- Dispatcher Methods ---

  /// Get stream of unassigned requests
  Stream<QuerySnapshot> getUnassignedRequests() {
    return _db
        .collection('ambulance_requests')
        .where('status', isEqualTo: 'requested')
        .where('assignedOperatorId', isNull: true)
        .snapshots();
  }

  /// Get stream of available operators (active and role=operator)
  Stream<QuerySnapshot> getAvailableOperators() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'operator')
        .where('active', isEqualTo: true)
        .snapshots();
  }

  /// Assign operator to request
  Future<void> assignOperator(String requestId, String operatorId) async {
    try {
      await _db.collection('ambulance_requests').doc(requestId).update({
        'assignedOperatorId': operatorId,
        'assignedAt': FieldValue.serverTimestamp(),
        'status':
            'on_the_way', // Automatically set to on_the_way or keep requested? Let's keep requested or move to 'assigned'?
        // The requirement says "Operator gets notification, Request becomes visible".
        // Usually, assignment doesn't mean "on the way" yet, but for simplicity let's keep it 'requested' or update to a new status if needed.
        // However, the existing statuses are 'requested', 'on_the_way', 'arrived', 'completed'.
        // If we assign, it's still 'requested' until the operator accepts/starts?
        // Let's just update the assignment fields. The operator can then change status to 'on_the_way'.
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update operator's assigned list
      await _db.collection('users').doc(operatorId).update({
        'assignedRequests': FieldValue.arrayUnion([requestId]),
      });

      debugPrint("✅ Operator assigned: $operatorId to request: $requestId");
    } catch (e) {
      debugPrint("❌ Error assigning operator: $e");
      rethrow;
    }
  }

  // --- Operator Methods ---

  /// Get requests assigned to specific operator
  Stream<QuerySnapshot> getOperatorRequests(String operatorId) {
    return _db
        .collection('ambulance_requests')
        .where('assignedOperatorId', isEqualTo: operatorId)
        .where('status',
            whereIn: ['requested', 'on_the_way', 'arrived']) // Only active ones
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Toggle Shift Status
  Future<void> toggleShiftStatus(String userId, bool isActive) async {
    try {
      final now = FieldValue.serverTimestamp();
      await _db.collection('users').doc(userId).update({
        'active': isActive,
        if (isActive) 'shiftStart': now,
        if (!isActive) 'shiftEnd': now,
        'lastUpdated': now,
      });
      debugPrint("✅ Shift status updated: $isActive");
    } catch (e) {
      debugPrint("❌ Error updating shift status: $e");
      rethrow;
    }
  }
}
