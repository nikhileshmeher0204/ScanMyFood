import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/auth_result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Exposes the auth state stream for reactive UI updates.
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Gets the currently authenticated user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  /// Helper to generate a random nonce for Apple Sign-In.
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Helper to generate SHA256 hash of a string.
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Authenticates using Google Sign-In.
  Future<AuthResult> signInWithGoogle() async {
    try {
      logger.i("AuthService: Starting Google Sign-In...");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        logger.w("AuthService: Google Sign-In cancelled by user");
        return const AuthResult.failure(
          "Sign-in cancelled",
          AuthErrorType.cancelled,
        );
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      logger.i("AuthService: Google Sign-In successful");
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      logger.e("AuthService: Firebase error during Google Sign-In: ${e.code} - ${e.message}");
      return _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("AuthService: Unexpected error during Google Sign-In: $e");
      return AuthResult.failure(
        "An unexpected error occurred: ${e.toString()}",
        AuthErrorType.unknown,
      );
    }
  }

  /// Authenticates using Sign in with Apple.
  Future<AuthResult> signInWithApple() async {
    try {
      logger.i("AuthService: Starting Apple Sign-In...");
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      await _auth.signInWithCredential(credential);
      logger.i("AuthService: Apple Sign-In successful");
      return const AuthResult.success();
    } on SignInWithAppleAuthorizationException catch (e) {
      logger.w("AuthService: Apple Sign-In cancelled or failed: ${e.code} - ${e.message}");
      if (e.code == AuthorizationErrorCode.canceled) {
        return const AuthResult.failure(
          "Sign-in cancelled",
          AuthErrorType.cancelled,
        );
      }
      return AuthResult.failure(
        "Apple Sign-In failed: ${e.message}",
        AuthErrorType.unknown,
      );
    } on FirebaseAuthException catch (e) {
      logger.e("AuthService: Firebase error during Apple Sign-In: ${e.code} - ${e.message}");
      return _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("AuthService: Unexpected error during Apple Sign-In: $e");
      return AuthResult.failure(
        "An unexpected error occurred: ${e.toString()}",
        AuthErrorType.unknown,
      );
    }
  }

  /// Authenticates using Email and Password.
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      logger.i("AuthService: Starting Email/Password Sign-In...");
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      logger.i("AuthService: Email Sign-In successful");
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      logger.e("AuthService: Firebase error during Email Sign-In: ${e.code} - ${e.message}");
      return _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("AuthService: Unexpected error during Email Sign-In: $e");
      return AuthResult.failure(
        "An unexpected error occurred",
        AuthErrorType.unknown,
      );
    }
  }

  /// Registers a new user with Email and Password.
  Future<AuthResult> registerWithEmail(String email, String password) async {
    try {
      logger.i("AuthService: Registering new user with Email/Password...");
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      logger.i("AuthService: Email Registration successful");
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      logger.e("AuthService: Firebase error during registration: ${e.code} - ${e.message}");
      return _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("AuthService: Unexpected error during registration: $e");
      return AuthResult.failure(
        "An unexpected error occurred",
        AuthErrorType.unknown,
      );
    }
  }

  /// Sends a password reset link to the user's email.
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      logger.i("AuthService: Sending password reset email to $email...");
      await _auth.sendPasswordResetEmail(email: email.trim());
      logger.i("AuthService: Password reset email sent successfully");
      return const AuthResult.success();
    } on FirebaseAuthException catch (e) {
      logger.e("AuthService: Firebase error during password reset: ${e.code} - ${e.message}");
      return _mapFirebaseAuthException(e);
    } catch (e) {
      logger.e("AuthService: Unexpected error during password reset: $e");
      return AuthResult.failure(
        "An unexpected error occurred",
        AuthErrorType.unknown,
      );
    }
  }

  /// Maps a Firebase authentication exception to a structured [AuthResult].
  AuthResult _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
      case 'wrong-password':
      case 'user-not-found':
      case 'invalid-credential':
        return const AuthResult.failure(
          "Invalid email or password. Please try again.",
          AuthErrorType.invalidCredential,
        );
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        return const AuthResult.failure(
          "This email is already registered with Google or Apple. Please sign in using your existing social account.",
          AuthErrorType.emailAlreadyInUse,
        );
      case 'weak-password':
        return const AuthResult.failure(
          "Password must be at least 6 characters long.",
          AuthErrorType.weakPassword,
        );
      case 'network-request-failed':
        return const AuthResult.failure(
          "Connection error. Please check your internet connectivity.",
          AuthErrorType.networkError,
        );
      case 'too-many-requests':
        return const AuthResult.failure(
          "Too many failed login attempts. Please try again later.",
          AuthErrorType.tooManyRequests,
        );
      case 'user-disabled':
        return const AuthResult.failure(
          "This account has been disabled.",
          AuthErrorType.unknown,
        );
      default:
        return AuthResult.failure(
          e.message ?? "Authentication failed",
          AuthErrorType.unknown,
        );
    }
  }

  /// Signs out of Firebase and all external auth providers.
  Future<void> signOut() async {
    try {
      logger.i("AuthService: Signing out...");
      await _googleSignIn.signOut();
      await _auth.signOut();
      logger.i("AuthService: Signed out successfully");
    } catch (e) {
      logger.e("AuthService: Error during sign-out: $e");
      rethrow;
    }
  }

  void dispose() {}
}
