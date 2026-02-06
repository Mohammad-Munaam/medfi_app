import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn();

  Future<GoogleSignInAccount?> signIn() async {
    return _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
