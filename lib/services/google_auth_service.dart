import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleSignIn _instance = GoogleSignIn.instance;
  
  GoogleSignIn get _googleSignIn => _instance;

  Future<GoogleSignInAccount?> signIn() async {
    try {
      await _googleSignIn.initialize();
      return await _googleSignIn.authenticate();
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
