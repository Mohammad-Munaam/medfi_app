// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  LatLng _currentPosition = const LatLng(37.422, -122.084);
  Set<Marker> _markers = {};

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
          _updateMarker(_currentPosition);
        });
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentPosition),
        );
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  void _updateMarker(LatLng pos) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('driver'),
          position: pos,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'You (Driver)'),
        ),
      };
    });
  }

  void _toggleTracking() {
    if (_isTracking) {
      _trackingService.stopTracking();
    } else {
      _trackingService.startDriverTracking(widget.requestId);

      // Listen locally to update map UI
      _locationService.getPositionStream().listen((pos) {
        if (!mounted) return;
        final newPos = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentPosition = newPos;
          _updateMarker(newPos);
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
      appBar: AppBar(
        title: const Text('Driver Mode'),
        backgroundColor: _isTracking ? Colors.green : Colors.grey,
        actions: [
          Switch(
            value: _isTracking,
            onChanged: (val) => _toggleTracking(),
            activeColor: Colors.white,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isTracking ? "ONLINE - Sharing Location" : "OFFLINE",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isTracking ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Request ID: ${widget.requestId.substring(0, 8)}...",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
