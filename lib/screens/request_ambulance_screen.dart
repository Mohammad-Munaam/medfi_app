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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter emergency details"),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Validate Location
      if (_pickedLocation == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select a pickup location on map")),
        );
        return;
      }

      // 2. Navigate to Driver Selection
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Navigate to Driver Selection Screen
      // Passing details and selected location to next screen
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
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Ambulance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Emergency Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            TextField(
              controller: _detailsController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe the emergency...",
                filled: true,
                fillColor: const Color(0xFFF4F1FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 📍 LOCATION PICKER SECTION
            const Text(
              "Pickup Location",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
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
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F1FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _pickedLocation != null
                        ? Colors.redAccent
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: _pickedLocation != null
                          ? Colors.redAccent
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pickedLocation == null
                            ? "Select Pickup Point on Map"
                            : "Selected: $_addressText",
                        style: TextStyle(
                          color: _pickedLocation == null
                              ? Colors.grey[600]
                              : Colors.black,
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

            const SizedBox(height: 30),

            // 🔹 GRADIENT CTA BUTTON + LOADING STATE
            GestureDetector(
              onTap: _isLoading ? null : _submitRequest,
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? null
                      : const LinearGradient(
                          colors: [
                            Colors.redAccent,
                            Colors.deepOrange,
                          ],
                        ),
                  color: _isLoading ? Colors.grey.shade300 : null,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.redAccent,
                          ),
                        )
                      : const Text(
                          "Confirm Ambulance Request",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
