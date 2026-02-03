import 'package:flutter/material.dart';

class UIHelpers {
  static void showLoading(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  static void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }
}
