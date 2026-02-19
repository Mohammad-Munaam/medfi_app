package com.medfi.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin
import io.flutter.plugins.firebase.analytics.FlutterFirebaseAnalyticsPlugin
import io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin
import io.flutter.plugins.firebase.crashlytics.FlutterFirebaseCrashlyticsPlugin
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin
import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin
import io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin
import com.baseflow.geolocator.GeolocatorPlugin
import io.flutter.plugins.googlemaps.GoogleMapsPlugin
import io.flutter.plugins.googlesignin.GoogleSignInPlugin
import com.lyokone.location.LocationPlugin
// url_launcher is commented out in pubspec, so don't import it here yet.
// import io.flutter.plugins.urllauncher.UrlLauncherPlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            // Manual registration to bypass corruption of GeneratedPluginRegistrant
            flutterEngine.plugins.add(FlutterFirebaseFirestorePlugin())
            flutterEngine.plugins.add(FlutterFirebaseAnalyticsPlugin())
            flutterEngine.plugins.add(FlutterFirebaseAuthPlugin())
            flutterEngine.plugins.add(FlutterFirebaseCorePlugin())
            flutterEngine.plugins.add(FlutterFirebaseCrashlyticsPlugin())
            flutterEngine.plugins.add(FlutterFirebaseMessagingPlugin())
            flutterEngine.plugins.add(FlutterLocalNotificationsPlugin())
            flutterEngine.plugins.add(FlutterAndroidLifecyclePlugin())
            flutterEngine.plugins.add(GeolocatorPlugin())
            flutterEngine.plugins.add(GoogleMapsPlugin())
            flutterEngine.plugins.add(GoogleSignInPlugin())
            flutterEngine.plugins.add(LocationPlugin())
            // flutterEngine.plugins.add(UrlLauncherPlugin())
        } catch (e: Exception) {
            // Log error
        }
    }
}
