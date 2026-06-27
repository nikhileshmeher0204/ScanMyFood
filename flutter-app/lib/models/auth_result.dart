/// Enumerates known authentication error types for structured UI handling.
///
/// Each value maps to one or more `FirebaseAuthException` codes,
/// allowing the UI to display provider-specific, user-friendly messages.
enum AuthErrorType {
  /// User cancelled the sign-in flow (e.g., dismissed Google/Apple sheet).
  cancelled,

  /// Device has no network connectivity.
  networkError,

  /// Email/password combination is incorrect.
  invalidCredential,

  /// The email address is already registered with a different provider.
  /// UI should tell the user which provider they originally used.
  emailAlreadyInUse,

  /// Password does not meet minimum strength requirements (< 6 chars).
  weakPassword,

  /// No account exists for the given email address.
  userNotFound,

  /// Too many failed attempts; account temporarily locked.
  tooManyRequests,

  /// Catch-all for unmapped Firebase error codes.
  unknown,
}

/// Represents the outcome of any authentication operation.
///
/// Usage:
/// ```dart
/// final result = await authService.signInWithGoogle();
/// if (result.success) {
///   // Navigate
/// } else {
///   showSnackBar(result.errorMessage!);
/// }
/// ```
class AuthResult {
  final bool success;
  final String? errorMessage;
  final AuthErrorType? errorType;

  /// Factory for a successful authentication result.
  const AuthResult.success()
      : success = true,
        errorMessage = null,
        errorType = null;

  /// Factory for a failed authentication result.
  const AuthResult.failure(String message, AuthErrorType type)
      : success = false,
        errorMessage = message,
        errorType = type;
}
