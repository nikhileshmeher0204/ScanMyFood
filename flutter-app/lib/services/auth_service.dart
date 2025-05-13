import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      //begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      //obtain auth details from request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;

      //create new credentials for user
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      //finally, lets sign in
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    // Sign out of Google
    await _googleSignIn.signOut();
    // Sign out of Firebase
    return _auth.signOut();
  }

  // For clean disposal
  void dispose() {
    // Any cleanup code if needed
  }
}
