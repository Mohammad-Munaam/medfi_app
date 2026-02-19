import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log when a user creates an ambulance request
  static Future<void> logRequestCreated({String? requestId}) async {
    try {
      await _analytics.logEvent(
        name: 'request_created',
        parameters: {
          if (requestId != null) 'request_id': requestId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('⚠️ Analytics log failed: $e');
    }
  }

  /// Log when request status changes
  static Future<void> logStatusUpdated({
    required String requestId,
    required String newStatus,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'status_updated',
        parameters: {
          'request_id': requestId,
          'new_status': newStatus,
        },
      );
    } catch (e) {
      debugPrint('⚠️ Analytics log failed: $e');
    }
  }

  /// Log admin actions
  static Future<void> logAdminAction({
    required String action,
    String? requestId,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'admin_action',
        parameters: {
          'action': action,
          if (requestId != null) 'request_id': requestId,
        },
      );
    } catch (e) {
      debugPrint('⚠️ Analytics log failed: $e');
    }
  }
}
