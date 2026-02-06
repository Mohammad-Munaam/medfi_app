import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tracking_screen.dart';

class RequestAmbulanceScreen extends StatefulWidget {
  const RequestAmbulanceScreen({super.key});

  @override
  State<RequestAmbulanceScreen> createState() =>
      _RequestAmbulanceScreenState();
}

class _RequestAmbulanceScreenState extends State<RequestAmbulanceScreen> {
  final TextEditingController _detailsController = TextEditingController();

  bool _isLoading = false;

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

    // ⏳ Simulate request processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // ✅ Smooth transition to tracking screen
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const TrackingScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
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
