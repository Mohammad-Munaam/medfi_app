import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Settings",
          style:
              TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildMenuItem("My profile"),
          _buildMenuItem("My Vehicle"),
          _buildMenuItem("Personal Document"),
          _buildMenuItem("Bank details"),
          _buildMenuItem("Change password"),

          // HELP section header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            color: const Color(0xFFF5F7F9),
            child: const Text(
              "HELP",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),

          _buildMenuItem("Terms & Conditions"),
          _buildMenuItem("Privacy Policies"),
          _buildMenuItem("About"),
          _buildMenuItem("Contact us"),
          _buildMenuItem("Contact us"), // Double in screenshot
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF333333),
              fontWeight: FontWeight.w400,
            ),
          ),
          onTap: () {},
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ],
    );
  }
}
