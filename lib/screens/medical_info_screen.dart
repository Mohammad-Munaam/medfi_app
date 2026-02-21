import 'package:flutter/material.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final _bloodTypeController = TextEditingController(text: "B+ve");
  final _heightController = TextEditingController(text: "170");
  final _weightController = TextEditingController(text: "85");
  String _organDonorStatus = "No";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Medical Information",
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
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField("Blood Type", _bloodTypeController),
            const SizedBox(height: 25),
            _buildField("Height (in cms)", _heightController),
            const SizedBox(height: 25),
            _buildField("Weight (in kgs)", _weightController),
            const SizedBox(height: 25),
            _buildLabel("Organ Donor Status"),
            const SizedBox(height: 10),
            Text(
              _organDonorStatus,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Divider(height: 20, color: Color(0xFFEEEEEE)),
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
          fontSize: 20, color: Color(0xFF444444), fontWeight: FontWeight.w400),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
          decoration: const InputDecoration(
            border: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEEEEEE))),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEEEEEE))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFEEEEEE))),
          ),
        ),
      ],
    );
  }
}
