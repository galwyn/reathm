import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '591919076410-68tmquddki886p0n0gcicf9i5opg1i81.apps.googleusercontent.com' : null,
    serverClientId: !kIsWeb ? '591919076410-68tmquddki886p0n0gcicf9i5opg1i81.apps.googleusercontent.com' : null,
  );

  static GoogleSignIn get googleSignIn => _googleSignIn;
}
