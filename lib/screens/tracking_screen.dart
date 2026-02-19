// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medfi_app/services/tracking_service.dart';

class TrackingScreen extends StatefulWidget {
  final String requestId;

  const TrackingScreen({super.key, required this.requestId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with SingleTickerProviderStateMixin {
  final TrackingService _trackingService = TrackingService();

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng? _driverLocation;
  LatLng? _userLocation;
  String _status = 'requested';
  String _eta = 'Calculating...';
  bool _isFirstLoad = true;
  StreamSubscription? _requestSubscription;

  // Animation
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  Timer? _animationTimer;

  // New styles
  static const Color _primaryColor = Color(0xFF1A237E); // Deep Indigo

  @override
  void initState() {
    super.initState();
    _setupPulseAnimation();
    _startLiveTracking();
  }

  void _setupPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.1).animate(_pulseController!);
  }

  void _startLiveTracking() {
    _requestSubscription = _trackingService
        .streamDriverLocation(widget.requestId)
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      // Update Status
      final newStatus = data['status'] as String? ?? 'requested';
      setState(() {
        _status = newStatus;
      });

      // Handle Completion
      if (newStatus == 'completed') {
        _pulseController?.stop();
        _animationTimer?.cancel();
        // Optionally show dialog or navigate back
      }

      // Update User Location (Static or from request)
      if (_userLocation == null && data['location'] != null) {
        final locationData = data['location'];
        if (locationData is GeoPoint) {
          _userLocation = LatLng(locationData.latitude, locationData.longitude);
        } else if (locationData is Map<String, dynamic>) {
          _userLocation = LatLng(
            (locationData['latitude'] as num).toDouble(),
            (locationData['longitude'] as num).toDouble(),
          );
        }
      }

      // Update Driver Location
      if (data['driverLocation'] != null) {
        final dLoc = data['driverLocation'] as Map<String, dynamic>;
        final newDriverPos = LatLng(dLoc['latitude'], dLoc['longitude']);
        final double heading = (dLoc['heading'] as num?)?.toDouble() ?? 0.0;

        _animateMarkerTo(newDriverPos, heading);
        _updatePolyline(newDriverPos);
        _calculateETA(newDriverPos);
      }
    });
  }

  // Smooth Marker Animation
  void _animateMarkerTo(LatLng newPos, double newHeading) {
    if (_driverLocation == null) {
      // First update, just set it
      setState(() {
        _driverLocation = newPos;
        _updateMarkers(newHeading);
      });
      if (_isFirstLoad && _mapController != null) {
        _fitBounds();
        _isFirstLoad = false;
      }
      return;
    }

    final startPos = _driverLocation!;
    final latDiff = newPos.latitude - startPos.latitude;
    final lngDiff = newPos.longitude - startPos.longitude;

    // Cancel previous animation
    _animationTimer?.cancel();

    // Animate over 1 second (approximate update interval filler)
    int steps = 20;
    int currentStep = 0;
    const duration = Duration(milliseconds: 50); // 20 * 50ms = 1000ms

    _animationTimer = Timer.periodic(duration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      currentStep++;
      final double t = currentStep / steps;
      final lat = startPos.latitude + (latDiff * t);
      final lng = startPos.longitude + (lngDiff * t);

      setState(() {
        _driverLocation = LatLng(lat, lng);
        _updateMarkers(newHeading);
      });

      if (currentStep >= steps) {
        timer.cancel();
      }
    });
  }

  void _updateMarkers(double heading) {
    Set<Marker> newMarkers = {};

    // User Marker
    if (_userLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: _userLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    // Driver Marker
    if (_driverLocation != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('ambulance'),
          position: _driverLocation!,
          rotation: heading,
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue), // Replace with custom icon ideally
          anchor: const Offset(0.5, 0.5),
          zIndex: 2,
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  void _updatePolyline(LatLng driverPos) {
    if (_userLocation == null) return;

    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: [driverPos, _userLocation!],
          color: _primaryColor,
          width: 5,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      };
    });
  }

  void _calculateETA(LatLng driverPos) {
    if (_userLocation == null) return;

    // Haversine distance
    const R = 6371; // Earth radius in km
    final dLat = _degToRad(_userLocation!.latitude - driverPos.latitude);
    final dLon = _degToRad(_userLocation!.longitude - driverPos.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(driverPos.latitude)) *
            cos(_degToRad(_userLocation!.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distanceKm = R * c;

    // Assume average city speed 30km/h
    final timeHours = distanceKm / 30.0;
    final minutes = (timeHours * 60).round();

    setState(() {
      if (minutes < 1) {
        _eta = "Arriving";
      } else {
        _eta = "$minutes min";
      }
    });
  }

  double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  void _fitBounds() {
    if (_mapController == null ||
        _userLocation == null ||
        _driverLocation == null) return;

    LatLngBounds bounds;
    if (_userLocation!.latitude > _driverLocation!.latitude &&
        _userLocation!.longitude > _driverLocation!.longitude) {
      bounds =
          LatLngBounds(southwest: _driverLocation!, northeast: _userLocation!);
    } else if (_userLocation!.longitude > _driverLocation!.longitude) {
      bounds = LatLngBounds(
          southwest:
              LatLng(_userLocation!.latitude, _driverLocation!.longitude),
          northeast:
              LatLng(_driverLocation!.latitude, _userLocation!.longitude));
    } else if (_userLocation!.latitude > _driverLocation!.latitude) {
      bounds = LatLngBounds(
          southwest:
              LatLng(_driverLocation!.latitude, _userLocation!.longitude),
          northeast:
              LatLng(_userLocation!.latitude, _driverLocation!.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: _userLocation!, northeast: _driverLocation!);
    }

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  void dispose() {
    _requestSubscription?.cancel();
    _pulseController?.dispose();
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.422, -122.084), // Default fallback
              zoom: 14,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              if (mounted) setState(() {});
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Status & ETA Card
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _pulseAnimation!,
              builder: (context, child) {
                return Transform.scale(
                  scale: _status == 'on_the_way' ? _pulseAnimation!.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(_status),
                            color: _getStatusColor(_status),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusText(_status).toUpperCase(),
                            style: TextStyle(
                              color: _getStatusColor(_status),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Estimated Arrival",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _eta,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _primaryColor,
                              ),
                            ),
                          ],
                        ),
                        // Driver Avatar / Icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'on_the_way':
        return _primaryColor;
      case 'arrived':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return _primaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'requested':
        return Icons.access_time;
      case 'on_the_way':
        return Icons.directions_car;
      case 'arrived':
        return Icons.check_circle;
      case 'completed':
        return Icons.flag;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    return status.replaceAll('_', ' ');
  }
}
