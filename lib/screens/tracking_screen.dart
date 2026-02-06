import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  static const Duration _initialEta = Duration(minutes: 8);
  static const Duration _tickInterval = Duration(seconds: 1);
  static const LatLng _ambulancePosition = LatLng(28.6139, 77.2090);
  static const LatLng _userPosition = LatLng(28.6129, 77.2295);

  late Duration _etaRemaining;
  Timer? _etaTimer;
  bool _pulse = false;

  @override
  void initState() {
    super.initState();
    _etaRemaining = _initialEta;
    _etaTimer = Timer.periodic(_tickInterval, (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _etaRemaining = _etaRemaining - _tickInterval;
        if (_etaRemaining.inSeconds <= 0) {
          _etaRemaining = Duration.zero;
          _etaTimer?.cancel();
        }
        _pulse = !_pulse;
      });
    });
  }

  @override
  void dispose() {
    _etaTimer?.cancel();
    super.dispose();
  }

  String _formatEta(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFF8),
      appBar: AppBar(
        title: const Text("Ambulance Tracking"),
        backgroundColor: const Color(0xFF1B8F3A),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMap(),
          ),
          _buildStatusCard(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return Container(
        color: const Color(0xFFB71C1C),
        alignment: Alignment.center,
        child: const Text(
          'Live map is available on Android',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: _ambulancePosition,
        zoom: 13,
      ),
      markers: {
        const Marker(
          markerId: MarkerId('ambulance'),
          position: _ambulancePosition,
          infoWindow: InfoWindow(title: 'Ambulance'),
        ),
        const Marker(
          markerId: MarkerId('user'),
          position: _userPosition,
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      },
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildStatusCard() {
    final etaText = _etaRemaining == Duration.zero
        ? 'Arrived'
        : _formatEta(_etaRemaining);

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: _pulse ? 14 : 10,
                height: _pulse ? 14 : 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF1B8F3A),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _etaRemaining == Duration.zero
                    ? 'Status: Arrived'
                    : 'Status: En route',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('ETA: $etaText'),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Driver: Rahul Sharma'),
          const SizedBox(height: 4),
          const Text('Vehicle: DL 01 AB 2345'),
        ],
      ),
    );
  }
}
