import 'package:flutter/material.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  bool _audioAlerts = false;
  bool _enableHelpButton = true;
  bool _shortcutFromLockScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Accessibility",
          style:
              TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            _buildSwitchTile(
              "Audio Alerts",
              value: _audioAlerts,
              onChanged: (val) => setState(() => _audioAlerts = val),
            ),
            const SizedBox(height: 10),
            _buildSwitchTile(
              "Enable HELP button",
              subtitle: "Help Button responds to fastest MEDFI services.",
              value: _enableHelpButton,
              onChanged: (val) => setState(() => _enableHelpButton = val),
            ),
            const SizedBox(height: 10),
            _buildSwitchTile(
              "Shortcut from Lock Screen",
              value: _shortcutFromLockScreen,
              onChanged: (val) => setState(() => _shortcutFromLockScreen = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title,
      {String? subtitle,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Column(
      children: [
        SwitchListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          title: Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF333333),
                fontWeight: FontWeight.w400),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                )
              : null,
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF4CAF50),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
      ],
    );
  }
}
