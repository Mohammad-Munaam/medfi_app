import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'driver_selection_screen.dart';
import 'location_picker_screen.dart';

class RequestAmbulanceScreen extends StatefulWidget {
  const RequestAmbulanceScreen({super.key});

  @override
  State<RequestAmbulanceScreen> createState() => _RequestAmbulanceScreenState();
}

class _RequestAmbulanceScreenState extends State<RequestAmbulanceScreen> {
  final TextEditingController _detailsController = TextEditingController();

  bool _isLoading = false;
  LatLng? _pickedLocation;
  String? _addressText;

  void _submitRequest() async {
    if (_detailsController.text.trim().isEmpty) {
      _showMessage("Please enter emergency details");
      return;
    }

    if (_pickedLocation == null) {
      _showMessage("Please select a pickup location on map");
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      // Simulate/Transition
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DriverSelectionScreen(
            details: _detailsController.text.trim(),
            lat: _pickedLocation!.latitude,
            lng: _pickedLocation!.longitude,
          ),
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      _showMessage("Error: $e");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Dark Header
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
                      "Request Ambulance",
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Emergency Details"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _detailsController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Describe the emergency...",
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildLabel("Pickup Location"),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final LatLng? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationPickerScreen(
                            initialLocation: _pickedLocation,
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          _pickedLocation = result;
                          _addressText =
                              "${result.latitude.toStringAsFixed(4)}, ${result.longitude.toStringAsFixed(4)}";
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _pickedLocation != null
                                ? const Color(0xFF4CAF50)
                                : Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: _pickedLocation != null
                                ? const Color(0xFF4CAF50)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              _pickedLocation == null
                                  ? "Select Pickup Point on Map"
                                  : "Selected: $_addressText",
                              style: TextStyle(
                                color: _pickedLocation == null
                                    ? Colors.grey
                                    : const Color(0xFF333333),
                                fontWeight: _pickedLocation != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "CONFIRM REQUEST",
                              style: TextStyle(
                                  fontSize: 18,
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

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5),
    );
  }
}
