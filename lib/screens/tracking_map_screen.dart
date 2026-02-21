import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/driver_model.dart';
import '../widgets/driver_bottom_panel.dart';

class TrackingMapScreen extends StatefulWidget {
  final DriverModel driver;

  const TrackingMapScreen({super.key, required this.driver});

  @override
  State<TrackingMapScreen> createState() => _TrackingMapScreenState();
}

class _TrackingMapScreenState extends State<TrackingMapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Timer? _timer;
  late double _currentLat;
  late double _currentLng;

  // Destination: User Mock Location (Bangalore center for demo)
  final double _destLat = 12.9716;
  final double _destLng = 77.5946;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.driver.currentLat;
    _currentLng = widget.driver.currentLng;
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _currentLat += (_destLat - _currentLat) * 0.05;
        _currentLng += (_destLng - _currentLng) * 0.05;
        _updateUI();
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(_currentLat, _currentLng)),
      );
    });
  }

  void _updateUI() {
    _markers.clear();

    // Ambulance Marker
    _markers.add(
      Marker(
        markerId: const MarkerId("ambulance"),
        position: LatLng(_currentLat, _currentLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: widget.driver.name, snippet: "Ambulance"),
      ),
    );

    // Pickup Marker
    _markers.add(
      Marker(
        markerId: const MarkerId("pickup"),
        position: LatLng(_destLat, _destLng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: "Pickup Location"),
      ),
    );

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId("route"),
        points: [
          LatLng(_currentLat, _currentLng),
          LatLng(_destLat, _destLng),
        ],
        color: const Color(0xFF4CAF50),
        width: 6,
        geodesic: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentLat, _currentLng),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _updateUI();
              setState(() {});
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // Premium Dark Header Overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 15,
                bottom: 25,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF2B3340),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emergency,
                            color: Color(0xFF4CAF50), size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "En route to pickup",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your ambulance is being simulated for this demo",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          // DRAGGABLE DRIVER PANEL
          DriverBottomPanel(
            driver: widget.driver,
            eta:
                "${((LatLng(_currentLat, _currentLng).latitude - _destLat).abs() * 1000).toInt() + 2} min",
            distance:
                "${((LatLng(_currentLat, _currentLng).latitude - _destLat).abs() * 100 + (LatLng(_currentLng, _currentLng).longitude - _destLng).abs() * 100).toStringAsFixed(1)} km",
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
