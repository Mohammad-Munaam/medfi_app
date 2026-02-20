import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../core/services/location_service.dart';

class TrackingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _locationSubscription;

  // Throttling variables
  DateTime? _lastUpdateTime;
  Position? _lastLocation;

  // Configuration
  static const int _throttleSeconds = 5;
  static const double _minDistanceMeters = 10.0;

  /// Start sharing driver location for a specific request
  Future<void> startDriverTracking(String requestId) async {
    // 1. Check/Request Permissions
    bool hasPermission = await _locationService.checkPermission();
    if (!hasPermission) {
      debugPrint("❌ Location permission denied");
      return;
    }

    // 2. Listen to Location Updates
    _locationSubscription =
        _locationService.getPositionStream().listen((Position currentLocation) {
      _updateLocation(requestId, currentLocation);
    });

    debugPrint("📍 Driver tracking started for request: $requestId");
  }

  /// Stop sharing location
  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _locationService.dispose();
    debugPrint("🛑 Driver tracking stopped");
  }

  /// Update Firestore with throttling logic
  Future<void> _updateLocation(String requestId, Position location) async {
    final now = DateTime.now();

    // Check throttle time
    if (_lastUpdateTime != null) {
      final timeDiff = now.difference(_lastUpdateTime!).inSeconds;

      // Calculate distance if we have a previous location
      double distance = 0.0;
      if (_lastLocation != null) {
        distance = Geolocator.distanceBetween(
          _lastLocation!.latitude,
          _lastLocation!.longitude,
          location.latitude,
          location.longitude,
        );
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
