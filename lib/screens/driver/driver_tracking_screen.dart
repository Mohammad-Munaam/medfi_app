import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/tracking_service.dart';
import '../../core/services/location_service.dart';

class DriverTrackingScreen extends StatefulWidget {
  final String requestId;

  const DriverTrackingScreen({super.key, required this.requestId});

  @override
  State<DriverTrackingScreen> createState() => _DriverTrackingScreenState();
}

class _DriverTrackingScreenState extends State<DriverTrackingScreen> {
  final TrackingService _trackingService = TrackingService();
  final LocationService _locationService = LocationService();

  GoogleMapController? _mapController;
  bool _isTracking = false;
  LatLng _currentPosition =
      const LatLng(28.5606, 77.2520); // Near Sukhdev Vihar, Delhi
  Set<Marker> _markers = {};

  // Demo Data
  final String _pickupAddress =
      "1 Neelam Colony, Sukhdev Vihar, New Delhi - 110064";
  final String _patientName = "Suneel Pal";
  final String _eta = "15 min";
  final String _distance = "4.5 km";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final pos = await _locationService.getCurrentPosition();
      if (pos != null) {
        setState(() {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
          _updateMarkers();
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      _updateMarkers(); // Still show markers for demo
    }
  }

  void _updateMarkers() {
    setState(() {
      _markers = {
        // Ambulance Marker (Using a default icon for simplicity, in production would use BitmapDescriptor.fromAsset)
        Marker(
          markerId: const MarkerId('driver'),
          position: _currentPosition,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'Ambulance'),
        ),
        // Pickup Marker
        Marker(
          markerId: const MarkerId('pickup'),
          position: const LatLng(28.5620, 77.2505),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Patient Location'),
        ),
      };
    });
  }

  void _toggleTracking() {
    if (_isTracking) {
      _trackingService.stopTracking();
    } else {
      _trackingService.startDriverTracking(widget.requestId);
      _locationService.getPositionStream().listen((pos) {
        if (!mounted) return;
        final newPos = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentPosition = newPos;
          _updateMarkers();
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(newPos));
      });
    }

    setState(() {
      _isTracking = !_isTracking;
    });
  }

  @override
  void dispose() {
    _trackingService.stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // MAP
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            style: _mapStyle, // Custom light style for clean look
          ),

          // TOP FLOATING ADDRESS CARD
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F4FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_pin_circle,
                        color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _pickupAddress,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF333333), height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // NAVIGATE BUTTON
          Positioned(
            bottom: 270,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 10),
                ],
              ),
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text(
                  "Navigate",
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ),
            ),
          ),

          // BOTTOM PANEL
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 20, spreadRadius: 5),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ETA and Heartbeat line
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_eta,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomPaint(
                          size: const Size(double.infinity, 30),
                          painter: HeartbeatPainter(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(_distance,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333))),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Saviour text and Call
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Saviour is $_patientName",
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(width: 15),
                      IconButton(
                        onPressed: () =>
                            launchUrl(Uri.parse("tel:+919999999999")),
                        icon: const Icon(Icons.call_outlined,
                            color: Color(0xFF333333)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // START BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _toggleTracking(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isTracking ? "STOP" : "START",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final String _mapStyle = '''
[
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  }
]
''';
}

class HeartbeatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    double mid = size.height / 2;

    path.moveTo(0, mid);
    path.lineTo(size.width * 0.35, mid);

    // The heartbeat spike
    path.lineTo(size.width * 0.4, mid - 10);
    path.lineTo(size.width * 0.45, mid + 15);
    path.lineTo(size.width * 0.5, mid - 20);
    path.lineTo(size.width * 0.55, mid + 10);
    path.lineTo(size.width * 0.6, mid);

    path.lineTo(size.width * 0.9, mid);

    // Dot at the end
    canvas.drawPath(path, paint);
    canvas.drawCircle(
        Offset(size.width * 0.95, mid), 3, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
