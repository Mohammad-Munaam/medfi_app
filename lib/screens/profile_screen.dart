import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CircleAvatar(
              radius: 40,
              child: Icon(Icons.person, size: 40),
            ),
            SizedBox(height: 16),
            Text("Name: MEDFI User", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("Email: user@medfi.com", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
