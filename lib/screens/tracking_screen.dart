import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  GoogleMapController? _mapController;

  final LatLng _userLocation = const LatLng(28.6139, 77.2090);
  LatLng _ambulanceLocation = const LatLng(28.6000, 77.2000);

  String status = "Requested";
  String eta = "Calculating...";

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      setState(() {
        status = "On the way";
        eta = "5 mins";

        _ambulanceLocation = LatLng(
          _ambulanceLocation.latitude + 0.001,
          _ambulanceLocation.longitude + 0.001,
        );

        if (_ambulanceLocation.latitude >= _userLocation.latitude) {
          status = "Arrived";
          eta = "Arrived";
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ambulance Tracking")),
      body: Column(
        children: [
          Expanded(child: _buildMap()),
          _statusPanel(),
        ],
      ),
    );
  }

  // ✅ MOBILE-ONLY MAP
  Widget _buildMap() {
    if (kIsWeb) {
      return _mapPlaceholder();
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _userLocation,
        zoom: 14,
      ),
      onMapCreated: (controller) => _mapController = controller,
      markers: {
        Marker(
          markerId: const MarkerId("user"),
          position: _userLocation,
        ),
        Marker(
          markerId: const MarkerId("ambulance"),
          position: _ambulanceLocation,
        ),
      },
    );
  }

  Widget _mapPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Text(
        "Live map available on mobile app only",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _statusPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Status: $status",
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("ETA: $eta"),
          const Divider(),
          const Text("Driver: Rahul Sharma"),
          const Text("Vehicle: DL 01 AB 2345"),
        ],
      ),
    );
  }
}
