import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/driver_model.dart';
import 'tracking_screen.dart'; // Reuse the map logic by wrapping or extending,
// OR simpler: compose TrackingScreen or rebuild the UI here.
// Reusing TrackingScreen logic is complex without refactoring.
// For this task, I'll build a dedicated UI that embeds the TrackingScreen's map logic
// or simpler: Navigate to TrackingScreen but with an Overlay.
// ACTUALLY: The user asked for specific UI: Driver details + Live Map.
// TrackingScreen ALREADY represents "Live Map".
// So I will make DriverAssignedScreen a WRAPPER that shows detailed info
// and embeds the map from TrackingScreen or replicates it.
// To keep it clean, I'll basically use TrackingScreen code but enhanced.
// Ideally, refactor TrackingScreen to be a component.
// For now, I'll copy the core map logic to ensure custom UI requirements are met.

class DriverAssignedScreen extends StatefulWidget {
  final String requestId;

  const DriverAssignedScreen({super.key, required this.requestId});

  @override
  State<DriverAssignedScreen> createState() => _DriverAssignedScreenState();
}

class _DriverAssignedScreenState extends State<DriverAssignedScreen> {
  // We can actually reuse TrackingScreen for the MAP part and just adding a bottom sheet?
  // Let's reuse TrackingScreen and customize it via args?
  // Or better: DriverAssignedScreen IS the new TrackingScreen.
  // But let's follow the plan and create a separate file to be safe.

  // Actually, to avoid code duplication of the complex map logic (animations, streams),
  // I will make DriverAssignedScreen navigate to TrackingScreen
  // BUT TrackingScreen needs to be updated to show the DRIVER DETAILS which is the core requirement.

  // Wait, the plan says "Create DriverAssignedScreen.dart".
  // I'll implement it as a screen that fetches the driver and shows the map.

  @override
  Widget build(BuildContext context) {
    // Reuse TrackingScreen but it needs to show detailed driver info now.
    // I will return TrackingScreen here, but I need to modify TrackingScreen
    // to fetch and display the detailed driver info (Vehicle, Name, Phone).
    // Currently TrackingScreen has a simple "Status Card".

    // Instead of duplicating map logic, I will modify TrackingScreen
    // to fetch the Driver Details if a driver is assigned.
    return TrackingScreen(requestId: widget.requestId);
  }
}
