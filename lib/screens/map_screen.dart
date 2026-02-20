import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentLocation;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final hasPermission = await _locationService.checkPermission();
    if (!hasPermission) return;

    final loc = await _locationService.getCurrentPosition();
    if (loc != null) {
      setState(() {
        _currentLocation = LatLng(loc.latitude, loc.longitude);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Map')),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 15,
              ),
              myLocationEnabled: true,
              markers: {
                Marker(
                  markerId: const MarkerId('ambulance'),
                  position: _currentLocation!,
                  infoWindow: const InfoWindow(title: 'Ambulance'),
                )
              },
              onMapCreated: (_) {},
            ),
    );
  }
}
