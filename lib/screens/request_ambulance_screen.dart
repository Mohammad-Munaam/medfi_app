import 'package:flutter/material.dart';
import '../services/ambulance_service.dart';
import 'request_success_screen.dart';

class RequestAmbulanceScreen extends StatefulWidget {
  const RequestAmbulanceScreen({super.key});

  @override
  State<RequestAmbulanceScreen> createState() =>
      _RequestAmbulanceScreenState();
}

class _RequestAmbulanceScreenState extends State<RequestAmbulanceScreen> {
  final issueController = TextEditingController();
  final locationController = TextEditingController();
  final AmbulanceService ambulanceService = AmbulanceService();

  bool loading = false;

  void submitRequest() async {
    if (issueController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await ambulanceService.requestAmbulance(
        issue: issueController.text.trim(),
        location: locationController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const RequestSuccessScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to request ambulance")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Request Ambulance")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.emergency, size: 80, color: Colors.red),
            const SizedBox(height: 20),

            TextField(
              controller: issueController,
              decoration: const InputDecoration(
                labelText: "Medical Issue",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: "Current Location",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            loading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: submitRequest,
                child: const Text("Request Ambulance"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
