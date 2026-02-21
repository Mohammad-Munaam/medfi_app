import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/driver_model.dart';
import '../services/firestore_service.dart';
import 'tracking_map_screen.dart';

class DriverSelectionScreen extends StatefulWidget {
  final String details;
  final double lat;
  final double lng;

  const DriverSelectionScreen({
    super.key,
    required this.details,
    required this.lat,
    required this.lng,
  });

  @override
  State<DriverSelectionScreen> createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends State<DriverSelectionScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _selectedVehicleType = 'All';
  String? _selectedDriverId;
  DriverModel? _selectedDriver;
  bool _isLoading = false;

  final List<String> _vehicleTypes = [
    'All',
    'Basic',
    'ICU',
    'Oxygen',
    'Advanced',
  ];

  final List<DriverModel> _mockDrivers = [
    DriverModel(
      id: 'mock_1',
      name: 'Rajesh Kumar',
      phone: '+919876543210',
      vehicleType: 'Basic',
      vehicleNumber: 'KA 01 AM 1234',
      rating: 4.8,
      currentLat: 12.9716,
      currentLng: 77.5946,
      photoUrl: 'https://i.pravatar.cc/150?u=mock1',
    ),
    DriverModel(
      id: 'mock_2',
      name: 'Suresh Raina',
      phone: '+919876543211',
      vehicleType: 'ICU',
      vehicleNumber: 'KA 01 AM 5678',
      rating: 4.9,
      currentLat: 12.9720,
      currentLng: 77.5950,
      photoUrl: 'https://i.pravatar.cc/150?u=mock2',
    ),
    DriverModel(
      id: 'mock_3',
      name: 'Amit Shah',
      phone: '+919876543212',
      vehicleType: 'Oxygen',
      vehicleNumber: 'KA 01 AM 9012',
      rating: 4.7,
      currentLat: 12.9710,
      currentLng: 77.5940,
      photoUrl: 'https://i.pravatar.cc/150?u=mock3',
    ),
    DriverModel(
      id: 'mock_4',
      name: 'Priya Singh',
      phone: '+919876543213',
      vehicleType: 'Basic',
      vehicleNumber: 'KA 01 AM 3456',
      rating: 4.6,
      currentLat: 12.9725,
      currentLng: 77.5955,
      photoUrl: 'https://i.pravatar.cc/150?u=mock4',
    ),
    DriverModel(
      id: 'mock_5',
      name: 'Vikram Batra',
      phone: '+919876543214',
      vehicleType: 'ICU',
      vehicleNumber: 'KA 01 AM 7890',
      rating: 5.0,
      currentLat: 12.9705,
      currentLng: 77.5935,
      photoUrl: 'https://i.pravatar.cc/150?u=mock5',
    ),
  ];

  void _onSelectDriver(DriverModel driver) {
    setState(() {
      _selectedDriverId = driver.id;
      _selectedDriver = driver;
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedDriver == null) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    // In PRO mode, we navigate immediately to tracking screen
    // We can still try to save to Firebase in background if needed
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Background creation of request (optional for demo)
        _firestoreService.createAmbulanceRequest(
          userId: user.uid,
          details: widget.details,
          lat: widget.lat,
          lng: widget.lng,
          selectedDriverId: _selectedDriverId,
          vehicleType: _selectedDriver?.vehicleType,
        );
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TrackingMapScreen(driver: _selectedDriver!),
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Ambulance",
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // 1. Vehicle Type Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _vehicleTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final type = _vehicleTypes[index];
                final isSelected = _selectedVehicleType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedVehicleType = type;
                      _selectedDriverId = null;
                      _selectedDriver = null;
                    });
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  selectedColor: Colors.green.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.green.shade800 : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // 2. Driver List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mockDrivers.length,
              itemBuilder: (context, index) {
                final driver = _mockDrivers[index];
                if (_selectedVehicleType != 'All' &&
                    driver.vehicleType != _selectedVehicleType) {
                  return const SizedBox.shrink();
                }
                final isSelected = _selectedDriverId == driver.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => _onSelectDriver(driver),
                      borderRadius: BorderRadius.circular(24),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(driver.photoUrl!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        driver.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              size: 16, color: Colors.amber),
                                          Text(
                                            " ${driver.rating}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${driver.vehicleType} • ${driver.vehicleNumber}",
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 14,
                                          color: Colors.grey.shade400),
                                      const SizedBox(width: 4),
                                      Text(
                                        "2.${index + 1} km away",
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Confirm Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedDriver != null && !_isLoading
                      ? _confirmSelection
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "Book ${_selectedDriver?.vehicleType ?? 'Ambulance'}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
