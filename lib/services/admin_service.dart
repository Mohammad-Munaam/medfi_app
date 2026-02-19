import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetch user role from Firestore. Defaults to 'user' if not found.
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (!doc.exists) return 'user';

      final data = doc.data();
      return data?['role'] as String? ?? 'user';
    } catch (e) {
      debugPrint('❌ Error fetching user role: $e');
      return 'user'; // Default to user on error
    }
  }

  /// Stream all ambulance requests, optionally filtered by status.
  Stream<QuerySnapshot> streamAllRequests({String? statusFilter}) {
    Query query = _db
        .collection('ambulance_requests')
        .orderBy('createdAt', descending: true);

    if (statusFilter != null && statusFilter != 'all') {
      query = query.where('status', isEqualTo: statusFilter);
    }

    return query.limit(50).snapshots();
  }

  /// Update request status with optional driver info.
  /// Returns the userId of the request owner for notification purposes.
  Future<String?> updateRequestStatus({
    required String requestId,
    required String newStatus,
    String? driverName,
    String? ambulanceNumber,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (driverName != null && driverName.isNotEmpty) {
        updateData['driverName'] = driverName;
      }
      if (ambulanceNumber != null && ambulanceNumber.isNotEmpty) {
        updateData['ambulanceNumber'] = ambulanceNumber;
      }

      // Fetch userId before updating
      final doc = await _db
          .collection('ambulance_requests')
          .doc(requestId)
          .get()
          .timeout(const Duration(seconds: 10));

      final userId = doc.data()?['userId'] as String?;

      await _db
          .collection('ambulance_requests')
          .doc(requestId)
          .update(updateData)
          .timeout(const Duration(seconds: 10));

      debugPrint('✅ Admin updated request $requestId → $newStatus');
      AnalyticsService.logAdminAction(
        action: 'status_update_$newStatus',
        requestId: requestId,
      );
      return userId;
    } catch (e) {
      debugPrint('❌ Error updating request status: $e');
      rethrow;
    }
  }

  /// Get FCM token for a specific user (for notification targeting)
  Future<String?> getUserFcmToken(String userId) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 10));

      return doc.data()?['fcmToken'] as String?;
    } catch (e) {
      debugPrint('❌ Error getting user FCM token: $e');
      return null;
    }
  }
}
