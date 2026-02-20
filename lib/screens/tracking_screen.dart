// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _status = 'accepted';
  String _eta = 'Calculating...';
  bool _isFirstLoad = true;
  StreamSubscription? _requestSubscription;

  // Driver Details
  String? _driverName;

  // Animation
  Timer? _animationTimer;

  // Marker Icon
  BitmapDescriptor? _ambulanceIcon;

  // Waiting Timer for Arrival
  Timer? _waitingTimer;
  int _secondsWaiting = 0;
  String _waitingTimeDisplay = "00:00";
  String? _driverPhone;
  bool _isSimulating = false;

  // New styles
  static const Color _navGreen = Color(0xFF0D533A);
  static const Color _primaryColor = Color(0xFF1A237E);

  @override
  void initState() {
    super.initState();
    _loadCustomIcon();
    _startLiveTracking();
  }

  Future<void> _loadCustomIcon() async {
    _ambulanceIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/ambulance_marker.png',
    );
  }

  void _startLiveTracking() {
    _requestSubscription = _trackingService
        .streamDriverLocation(widget.requestId)
        .listen((snapshot) {
      if (!mounted || !snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;

      // Update Status
      final newStatus = data['status'] as String? ?? 'requested';
      if (_status != 'arrived' && newStatus == 'arrived') {
        _startWaitingTimer();
      } else if (_status == 'arrived' && newStatus != 'arrived') {
        _stopWaitingTimer();
      }

      setState(() {
        _status = newStatus;
      });

      // Handle Completion
      if (newStatus == 'completed') {
        _stopWaitingTimer();
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
        _calculateETA(newDriverPos);

        // Fetch Road Route once locations are available
        if (_userLocation != null && _isFirstLoad) {
          _fetchRoadRoute(newDriverPos, _userLocation!);
        }

        // Fetch Driver Details (if assigned and not yet fetched)
        final driverId = data['selectedDriverId'] as String?;
        if (driverId != null && _driverName == null) {
          _fetchDriverDetails(driverId);
        }
      }
    });
  }

  Future<void> _fetchDriverDetails(String driverId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _driverName = data['name'];
          _driverPhone = data['phone'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching driver details: $e");
    }
  }

  Future<void> _fetchRoadRoute(LatLng driverPos, LatLng userPos) async {
    final points = await _trackingService.getRoutePoints(driverPos, userPos);
    if (!mounted) return;
    setState(() {
      _polylines = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: _primaryColor,
          width: 5,
        ),
      };
      _isFirstLoad = false;
    });
    _fitBounds();
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
          icon: _ambulanceIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          anchor: const Offset(0.5, 0.5),
          zIndex: 2,
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
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

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  void _reCentre() {
    if (_driverLocation != null) {
      _mapController!
          .animateCamera(CameraUpdate.newLatLngZoom(_driverLocation!, 16));
    }
  }

  void _startWaitingTimer() {
    _stopWaitingTimer();
    _secondsWaiting = 0;
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsWaiting++;
        final minutes = (_secondsWaiting ~/ 60).toString().padLeft(2, '0');
        final seconds = (_secondsWaiting % 60).toString().padLeft(2, '0');
        _waitingTimeDisplay = "$minutes:$seconds";
      });
    });
  }

  void _stopWaitingTimer() {
    _waitingTimer?.cancel();
    _waitingTimer = null;
  }

  Future<void> _simulateTrip() async {
    if (_polylines.isEmpty || _isSimulating) return;

    final points = _polylines.first.points;
    if (points.isEmpty) return;

    setState(() {
      _isSimulating = true;
      _status = 'on_the_way';
    });

    for (int i = 0; i < points.length; i++) {
      if (!mounted || !_isSimulating) break;

      final currentPos = points[i];
      double heading = 0;

      if (i < points.length - 1) {
        heading = _calculateHeading(currentPos, points[i + 1]);
      }

      setState(() {
        _driverLocation = currentPos;
        // Mock ETA update
        int remainingMin =
            ((points.length - i) / points.length * 10).toInt() + 1;
        _eta = "$remainingMin min";

        // Update Markers
        final newMarkers = Set<Marker>.from(_markers);
        newMarkers.removeWhere((m) => m.markerId.value == 'ambulance');
        newMarkers.add(
          Marker(
            markerId: const MarkerId('ambulance'),
            position: currentPos,
            rotation: heading,
            icon: _ambulanceIcon ??
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            anchor: const Offset(0.5, 0.5),
            zIndex: 2,
          ),
        );
        _markers = newMarkers;
      });

      // Move camera slightly to follow
      if (i % 5 == 0) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(currentPos));
      }

      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) {
      setState(() {
        _isSimulating = false;
        _status = 'arrived';
        _startWaitingTimer();
      });
    }
  }

  double _calculateHeading(LatLng start, LatLng end) {
    final double lat1 = start.latitude * pi / 180;
    final double lon1 = start.longitude * pi / 180;
    final double lat2 = end.latitude * pi / 180;
    final double lon2 = end.longitude * pi / 180;

    final double dLon = lon2 - lon1;
    final double y = sin(dLon) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    final radians = atan2(y, x);
    return (radians * 180 / pi + 360) % 360;
  }

  @override
  void dispose() {
    _isSimulating = false;
    _requestSubscription?.cancel();
    _stopWaitingTimer();
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Map Layer
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.422, -122.084),
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
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // 1. Top Navigation Bar (Instruction Bar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              decoration: BoxDecoration(
                color: _status == 'arrived' ? Colors.blue[800] : _navGreen,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Icon(
                    _status == 'arrived'
                        ? Icons.check_circle
                        : Icons.navigation,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _status == 'arrived'
                              ? "Ambulance Arrived"
                              : (_status == 'on_the_way'
                                  ? "Picking up now"
                                  : "En route to pickup"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _status == 'arrived'
                              ? "Driver is at your location"
                              : (_driverName ?? "Hurry! Ambulance is coming"),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mic,
                      color:
                          _status == 'arrived' ? Colors.blue[800] : _navGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Side Control Buttons
          Positioned(
            right: 16,
            bottom: 140, // Above the bottom card
            child: Column(
              children: [
                _buildFloatingButton(
                  _isSimulating ? Icons.stop : Icons.play_arrow,
                  () {
                    if (_isSimulating) {
                      setState(() => _isSimulating = false);
                    } else {
                      _simulateTrip();
                    }
                  },
                  label: _isSimulating ? "Stop" : "Simulate",
                ),
                const SizedBox(height: 12),
                _buildFloatingButton(Icons.explore_outlined, () {}),
                const SizedBox(height: 12),
                _buildFloatingButton(Icons.volume_up_outlined, () {}),
                const SizedBox(height: 12),
                _buildFloatingButton(Icons.my_location, _reCentre,
                    label: "Re-centre"),
              ],
            ),
          ),

          // 3. Bottom Stats Card (Navigation Style)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle indicator
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close button
                      _buildIconButton(
                          Icons.close, () => Navigator.pop(context)),

                      // Centered Stats
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_status == 'arrived') ...[
                              Text(
                                _waitingTimeDisplay,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "waiting",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ] else ...[
                              Text(
                                _eta.replaceAll(" min", ""),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE67E22), // Orange for ETA
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "min",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE67E22),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _status == 'arrived'
                                      ? "Driver waiting"
                                      : "9.4 km",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _status == 'arrived'
                                      ? "Since arrival"
                                      : "3:16 pm",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // More/Navigation/Call button
                      _buildIconButton(
                        _status == 'arrived' ? Icons.phone : Icons.alt_route,
                        () {
                          if (_status == 'arrived' && _driverPhone != null) {
                            launchUrl(Uri.parse("tel:$_driverPhone"));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, VoidCallback onPressed,
      {String? label}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8)
              ],
            ),
            child: Icon(icon, color: Colors.black54),
          ),
        ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.navigation, size: 12, color: Colors.teal),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }
}
