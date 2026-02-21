import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medical_info_screen.dart';
import 'personal_info_screen.dart';
import 'accessibility_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String name = user?.displayName ??
        'Anuj Tiwari'; // Default for demo as per screenshot
    final String? photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2B3340),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Help", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 30),
            decoration: const BoxDecoration(
              color: const Color(0xFF2B3340),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl)
                        : const NetworkImage(
                            'https://i.pravatar.cc/150?u=anuj'), // Mock for demo
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              children: [
                _buildMenuItem(
                  context,
                  title: "Profile",
                  subtitle: "Update Profile",
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  title: "Edit Medical Information",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MedicalInfoScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  title: "Edit Personal Information",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PersonalInfoScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  title: "Accessibility",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AccessibilityScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  title: "Ratings",
                  onTap: () {},
                ),
                _buildMenuItem(
                  context,
                  title: "Settings",
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
                _buildMenuItem(
                  context,
                  title: "Logout",
                  showDivider: false,
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                )
              : null,
          onTap: onTap,
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
      ],
    );
  }
}
