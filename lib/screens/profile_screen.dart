import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 16),
            Text("Name: ${user?.displayName ?? 'User'}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Email: ${user?.email ?? 'Not logged in'}",
                style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
