import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/driver_model.dart';
import '../services/analytics_service.dart';
import '../services/firestore_service.dart';
import 'driver_assigned_screen.dart';

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
    'Basic Ambulance',
    'ICU Ambulance',
    'Advanced Life Support',
    'Patient Transport',
    'Rapid Response'
  ];

  void _onSelectDriver(DriverModel driver) {
    setState(() {
      _selectedDriverId = driver.id;
      _selectedDriver = driver;
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedDriverId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a driver")),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final requestId = await _firestoreService.createAmbulanceRequest(
        userId: user.uid,
        details: widget.details,
        lat: widget.lat,
        lng: widget.lng,
        selectedDriverId: _selectedDriverId,
        vehicleType: _selectedDriver?.vehicleType,
      );

      if (requestId != null) {
        AnalyticsService.logRequestCreated(requestId: requestId);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DriverAssignedScreen(requestId: requestId),
          ),
        );
      }
    } catch (e) {
      /* Handle error */
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Ambulance")),
      body: Column(
        children: [
          // 1. Vehicle Type Filter
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      _selectedDriverId =
                          null; // Reset selection on filter change
                    });
                  },
                  selectedColor: Colors.deepOrange.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.deepOrange : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // 2. Driver List
          Expanded(
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: _firestoreService.getNearbyDrivers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!;
                // Filter locally by vehicle type if not 'All'
                final drivers = docs
                    .map((d) => DriverModel.fromSnapshot(d))
                    .where((d) =>
                        _selectedVehicleType == 'All' ||
                        d.vehicleType == _selectedVehicleType)
                    .toList();

                if (drivers.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.commute, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("No drivers found nearby"),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: drivers.length,
                  itemBuilder: (context, index) {
                    final driver = drivers[index];
                    final isSelected = _selectedDriverId == driver.id;

                    return Card(
                      elevation: isSelected ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isSelected
                            ? const BorderSide(
                                color: Colors.deepOrange, width: 2)
                            : BorderSide.none,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _onSelectDriver(driver),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Avatar
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: driver.profilePhoto != null
                                    ? NetworkImage(driver.profilePhoto!)
                                    : null,
                                child: driver.profilePhoto == null
                                    ? const Icon(Icons.person,
                                        size: 30, color: Colors.grey)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${driver.vehicleType} • ${driver.vehicleNumber}",
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 14, color: Colors.amber),
                                        Text(
                                          " ${driver.rating}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Radio or Check
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: Colors.deepOrange),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 3. Confirm Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _selectedDriverId != null && !_isLoading
                      ? _confirmSelection
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          "Confirm ${_selectedDriver != null ? _selectedDriver!.name : 'Driver'}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
