import 'package:flutter/material.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _dobController = TextEditingController(text: "05/05/1987");
  final _genderController = TextEditingController(text: "Male");
  final _primaryPhoneController = TextEditingController(text: "9911654321");
  final _secondaryPhoneController = TextEditingController(text: "8800939044");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Personal Information",
          style:
              TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildFieldWithIcon(
                "DOB(DD/MM/YYYY)", _dobController, Icons.calendar_today),
            const SizedBox(height: 30),
            _buildLabel("Gender"),
            const SizedBox(height: 5),
            TextField(
              controller: _genderController,
              style: const TextStyle(fontSize: 18, color: Color(0xFF333333)),
              decoration: const InputDecoration(
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFEEEEEE))),
              ),
            ),
            const SizedBox(height: 30),
            _buildPhoneField(
                "Primary Emergency Number", _primaryPhoneController),
            const SizedBox(height: 30),
            _buildPhoneField(
                "Secondary Emergency Number", _secondaryPhoneController),
            const SizedBox(height: 40),
            Center(
              child: Text.rich(
                TextSpan(
                  text:
                      "By continuing, I confirm that i have read & agree to the\n",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  children: [
                    TextSpan(
                      text: "Terms & conditions",
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: " and "),
                    TextSpan(
                      text: "Privacy policy",
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: const Text(
                  "NEXT",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w400),
    );
  }

  Widget _buildFieldWithIcon(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 18, color: Color(0xFF333333)),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                ),
              ),
            ),
            Icon(icon, color: Colors.grey, size: 40),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 5),
        Row(
          children: [
            const Text("🇮🇳", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            const Text("+91",
                style: TextStyle(fontSize: 18, color: Color(0xFF333333))),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 18, color: Color(0xFF333333)),
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFEEEEEE))),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
