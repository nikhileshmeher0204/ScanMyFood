/// Mirrors the backend [GlobalExceptionHandler] ErrorResponse envelope:
/// {
///   "status": 404,
///   "error": "Not Found",
///   "errorCode": "ERR_1101",
///   "description": "User not found.",
///   "message": "No user exists with firebase uid: ...",
///   "path": "/api/users/user",
///   "timestamp": "..."
/// }
class ApiException implements Exception {
  final int statusCode;
  final String? errorCode;
  final String? error;
  final String? description;
  final String message;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.errorCode,
    this.error,
    this.description,
  });

  /// Parse directly from the server's ErrorResponse JSON body.
  factory ApiException.fromJson(int statusCode, Map<String, dynamic> json) {
    return ApiException(
      statusCode: statusCode,
      message: json['message'] as String? ?? 'Unknown error',
      errorCode: json['errorCode'] as String?,
      error: json['error'] as String?,
      description: json['description'] as String?,
    );
  }

  /// Fallback when the body is not a valid ErrorResponse.
  factory ApiException.raw(int statusCode, String body) {
    return ApiException(
      statusCode: statusCode,
      message: body.isNotEmpty ? body : 'HTTP $statusCode',
    );
  }

  bool get isNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;
  bool get isBadRequest => statusCode == 400;
  bool get isServerError => statusCode >= 500;

  @override
  String toString() =>
      'ApiException($statusCode${errorCode != null ? ' [$errorCode]' : ''}): $message';
}
