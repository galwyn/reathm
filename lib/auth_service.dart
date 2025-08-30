import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn();

  static GoogleSignIn get googleSignIn => _googleSignIn;
}
