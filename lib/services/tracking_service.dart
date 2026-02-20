import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  /// Fetch road-aware route points between two locations
  /// For MVP/Sim: If no API key is restricted, we'll try fetching or return mock road points
  Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
    const String apiKey =
        'AIzaSyCdeROgteunu0Da4YvH56icDDurySnNndw'; // Using existing key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final String polyline =
              data['routes'][0]['overview_polyline']['points'];
          return _decodePolyline(polyline);
        }
      }
      debugPrint("⚠️ Directions API failed, status: ${response.statusCode}");
    } catch (e) {
      debugPrint("❌ Error fetching route: $e");
    }

    // Fallback: Return straight line if API fails
    return [start, end];
  }

  /// Decodes encoded polyline string into List<LatLng>
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
