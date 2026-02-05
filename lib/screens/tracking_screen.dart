import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String status = "On the way";
  String eta = "5 mins";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ambulance Tracking"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // MAP / PLACEHOLDER AREA
          Expanded(
            child: kIsWeb ? _webMapPlaceholder() : _mobileMapPlaceholder(),
          ),

          // INFO PANEL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status: $status",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text("ETA: $eta"),
                const Divider(height: 24),
                const Text("Driver: Rahul Sharma"),
                const Text("Vehicle: DL 01 AB 2345"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // WEB SAFE PLACEHOLDER
  Widget _webMapPlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.map, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "Live map available on mobile app",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // MOBILE PLACEHOLDER (will be replaced by Google Map later)
  Widget _mobileMapPlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      child: const Center(
        child: Text(
          "Google Map Loading...",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
