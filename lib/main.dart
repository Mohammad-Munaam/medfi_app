import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'app.dart';
import 'utils/seed_drivers.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ).timeout(const Duration(seconds: 15));
      } else {
        await Firebase.initializeApp().timeout(const Duration(seconds: 15));
      }
    } catch (e) {
      debugPrint('🛑 Firebase init failed: $e');
    }

    // Initialize Crashlytics (release mode only)
    if (!kIsWeb) {
      try {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);

        // Route Flutter framework errors to Crashlytics
        FlutterError.onError = (details) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
          if (kDebugMode) {
            FlutterError.presentError(details);
          }
        };
      } catch (e) {
        debugPrint('⚠️ Crashlytics init failed: $e');
      }
    } else {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('🛑 Flutter Error: ${details.exceptionAsString()}');
      };
    }

    // Initialize local notifications
    try {
      await NotificationService.init();
    } catch (e) {
      debugPrint('⚠️ Notification init failed: $e');
    }

    // Initialize FCM
    try {
      final fcmService = FCMService();
      await fcmService.init();
    } catch (e) {
      debugPrint('⚠️ FCM init failed: $e');
    }

    // Seed dummy drivers (run once)
    try {
      await seedDummyDrivers();
    } catch (e) {
      debugPrint('⚠️ Seeding drivers failed: $e');
    }

    runApp(const MedfiApp());
  }, (error, stackTrace) {
    // Route async errors to Crashlytics in release, debugPrint in debug
    if (!kIsWeb && !kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, fatal: true);
    } else {
      debugPrint('🛑 Unhandled error: $error');
    }
  });
}
