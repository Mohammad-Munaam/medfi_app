import 'package:flutter/material.dart';
import 'request_success_screen.dart';

class RequestAmbulanceScreen extends StatelessWidget {
  const RequestAmbulanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF8),
      appBar: AppBar(
        title: const Text('Request Ambulance'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // ---- BACKGROUND IMAGE (NON-OVERLAPPING) ----
            Positioned(
              bottom: -40,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.08,
                child: Image.asset(
                  'assets/images/ambulance_bg.png',
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // ---- FOREGROUND CONTENT ----
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoCard(),
                  const SizedBox(height: 16),
                  _detailsCard(),
                  const SizedBox(height: 24),
                  _confirmButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- INFO CARD ----------------
  Widget _infoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.local_hospital, color: Colors.red, size: 36),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Emergency Ambulance',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Fastest available ambulance will be dispatched.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DETAILS CARD ----------------
  Widget _detailsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Request Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            _DetailRow(
              icon: Icons.location_on,
              label: 'Location',
              value: 'Using live GPS location',
            ),
            SizedBox(height: 8),
            _DetailRow(
              icon: Icons.access_time,
              label: 'Response Time',
              value: '5 – 10 minutes',
            ),
            SizedBox(height: 8),
            _DetailRow(
              icon: Icons.shield,
              label: 'Privacy',
              value: 'Location shared only during emergency',
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CONFIRM BUTTON ----------------
  Widget _confirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const RequestSuccessScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'Confirm Ambulance Request',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ---------------- REUSABLE ROW ----------------
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
