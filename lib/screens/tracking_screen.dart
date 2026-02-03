import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFF8),
      appBar: AppBar(
        title: const Text("Live Tracking"),
        backgroundColor: const Color(0xFF1B8F3A),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.local_hospital,
              size: 80,
              color: Color(0xFF1B8F3A),
            ),
            SizedBox(height: 20),
            Text(
              "Ambulance is on the way",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Live location tracking will appear here",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
