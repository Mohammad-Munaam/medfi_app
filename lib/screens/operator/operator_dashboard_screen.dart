import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/ambulance_request.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class OperatorDashboardScreen extends StatefulWidget {
  const OperatorDashboardScreen({super.key});

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isActive = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkShiftStatus();
  }

  Future<void> _checkShiftStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final userData = UserModel.fromFirestore(doc);
        if (mounted) {
          setState(() {
            _isActive = userData.active;
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _toggleShift(bool value) async {
    setState(() => _isActive = value);
    final user = _auth.currentUser;
    if (user != null) {
      await _firestoreService.toggleShiftStatus(user.uid, value);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _updateStatus(String requestId, String newStatus) async {
    await _firestoreService.updateRequestStatus(requestId, newStatus);
  }

  Future<void> _launchMaps(GeoPoint location) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) return const LoginScreen();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Operator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Shift Toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  color:
                      _isActive ? Colors.green.shade100 : Colors.red.shade100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isActive ? 'You are ONLINE' : 'You are OFFLINE',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isActive
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: _toggleShift,
                        activeTrackColor: Colors.green,
                      ),
                    ],
                  ),
                ),

                // Requests List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestoreService.getOperatorRequests(user.uid),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(
                          child: Text(
                            'No active assignments',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final request =
                              AmbulanceRequest.fromFirestore(docs[index]);
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Request #${request.id.substring(0, 8)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(request.details ?? 'No details'),
                                  const SizedBox(height: 8),
                                  if (request.location != null)
                                    ElevatedButton.icon(
                                      icon: const Icon(Icons.map),
                                      label: const Text('Navigate'),
                                      onPressed: () =>
                                          _launchMaps(request.location!),
                                    ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      if (request.status == 'requested' ||
                                          request.status == 'on_the_way')
                                        ElevatedButton(
                                          onPressed: () => _updateStatus(
                                              request.id, 'arrived'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                                          child: const Text('Arrived'),
                                        ),
                                      if (request.status == 'arrived')
                                        ElevatedButton(
                                          onPressed: () => _updateStatus(
                                              request.id, 'completed'),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green),
                                          child: const Text('Complete'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
