import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  /// Initialize local notification plugin (call once from main.dart)
  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings);
    debugPrint("✅ NotificationService initialized");
  }

  /// Show a local notification from a RemoteMessage (FCM)
  static void showNotification(RemoteMessage message) {
    const androidDetails = AndroidNotificationDetails(
      'medfi_alerts',
      'MEDFI Alerts',
      channelDescription: 'Emergency and status update notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'MEDFI Alert',
      message.notification?.body ?? 'Emergency update',
      notificationDetails,
    );
  }
}
