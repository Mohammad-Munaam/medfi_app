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

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
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
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Premium Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF2B3340),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Available Ambulances",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Vehicle Type Filter
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
                  selectedColor: const Color(0xFFE8F5E9),
                  checkmarkColor: const Color(0xFF4CAF50),
                  labelStyle: TextStyle(
                    color:
                        isSelected ? const Color(0xFF2E7D32) : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          // Driver List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
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
                  child: InkWell(
                    onTap: () => _onSelectDriver(driver),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFF8FDF9) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4CAF50)
                              : Colors.grey.shade100,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                  image: NetworkImage(driver.photoUrl!),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(driver.name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 14, color: Colors.amber),
                                        Text(" ${driver.rating}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                    "${driver.vehicleType} • ${driver.vehicleNumber}",
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("2.${index + 1} km away",
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Confirm Button
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4))
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedDriver != null && !_isLoading
                      ? _confirmSelection
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          "BOOK ${(_selectedDriver?.vehicleType ?? 'Ambulance').toUpperCase()}",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
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
