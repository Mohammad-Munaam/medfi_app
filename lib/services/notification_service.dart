import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 🔔 Request permission
    await _firebaseMessaging.requestPermission();

    // 🔑 Get FCM token
    final token = await _firebaseMessaging.getToken();
    debugPrint("FCM Token: $token");

    // 🔔 Local notification setup
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings);

    // 🔔 Foreground notifications
    FirebaseMessaging.onMessage.listen(_showNotification);
  }

  static void _showNotification(RemoteMessage message) {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails =
    NotificationDetails(android: androidDetails);

    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'MEDFI Alert',
      message.notification?.body ?? 'Emergency update',
      notificationDetails,
    );
  }
}
