import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';

class TrackingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Location _location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  // Throttling variables
  DateTime? _lastUpdateTime;
  LocationData? _lastLocation;

  // Configuration
  static const int _throttleSeconds = 5;
  static const double _minDistanceMeters = 10.0;

  /// Start sharing driver location for a specific request
  Future<void> startDriverTracking(String requestId) async {
    // 1. Check/Request Permissions
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // 2. Configure Location Settings for Driver (High Accuracy)
    await _location.changeSettings(
      accuracy: LocationAccuracy.navigation,
      interval: 5000, // 5 seconds
      distanceFilter: 10, // 10 meters
    );

    // 3. Listen to Location Updates
    _locationSubscription =
        _location.onLocationChanged.listen((LocationData currentLocation) {
      _updateLocation(requestId, currentLocation);
    });

    debugPrint("📍 Driver tracking started for request: $requestId");
  }

  /// Stop sharing location
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    debugPrint("🛑 Driver tracking stopped");
  }

  /// Update Firestore with throttling logic
  Future<void> _updateLocation(String requestId, LocationData location) async {
    final now = DateTime.now();

    // Check throttle time
    if (_lastUpdateTime != null) {
      final timeDiff = now.difference(_lastUpdateTime!).inSeconds;

      // Calculate distance if we have a previous location
      double distance = 0.0;
      if (_lastLocation != null) {
        // Simple distance approximation (sufficient for rough check)
        // In a real app, use Geolocator.distanceBetween()
        double latDiff = (location.latitude! - _lastLocation!.latitude!).abs();
        double lngDiff =
            (location.longitude! - _lastLocation!.longitude!).abs();
        // Roughly: 1 degree ~ 111km, so 0.0001 ~ 11m
        distance = (latDiff + lngDiff) * 100000;
      }

      // If less than throttle time AND moved less than minimum distance, skip update
      if (timeDiff < _throttleSeconds && distance < _minDistanceMeters) {
        return;
      }
    }

    // Update Firestore
    try {
      await _db.collection('ambulance_requests').doc(requestId).update({
        'driverLocation': {
          'latitude': location.latitude,
          'longitude': location.longitude,
          'heading': location.heading,
          'speed': location.speed,
          'timestamp': FieldValue.serverTimestamp(),
        },
      });

      _lastUpdateTime = now;
      _lastLocation = location;
      debugPrint(
          "✅ Location updated: ${location.latitude}, ${location.longitude}");
    } catch (e) {
      debugPrint("❌ Error updating location: $e");
    }
  }

  /// Stream driver location for the User App
  Stream<DocumentSnapshot> streamDriverLocation(String requestId) {
    return _db.collection('ambulance_requests').doc(requestId).snapshots();
  }
}
