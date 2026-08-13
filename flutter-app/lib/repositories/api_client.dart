import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:read_the_label/config/env_config.dart';
import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/api_exception.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? EnvConfig.apiBaseUrl;

  // Get auth token from Firebase
  Future<String?> getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  // Get the current user's UID
  String getCurrentUid() {
    final user = FirebaseAuth.instance.currentUser;
    return user!.uid;
  }

  // Get standardized headers for API requests
  Future<Map<String, String>> getRequestHeaders(
      {bool includeContentType = true}) async {
    final token = await getAuthToken();
    return {
      if (includeContentType) 'Content-Type': 'application/json',
      'X-User-Id': getCurrentUid(),
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Helper method for GET requests
  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      logger.d("Making GET request to: $uri");

      final response = await http
          .get(
            uri,
            headers: await getRequestHeaders(),
          )
          .timeout(const Duration(seconds: 15)); // Add timeout

      logger.d("Response status code: ${response.statusCode}");
      logger.d("Response body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"rawResponse": response.body};
        }
      } else {
        _throwApiException(response);
      }
    } catch (e) {
      logger.d("API call error with details: $e");
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        logger.d(
            "Connection error - check that your server is running and accessible");
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      logger.d("Making POST request to: $uri");
      final response = await http.post(
        uri,
        headers: await getRequestHeaders(),
        body: jsonEncode(data),
      );

      logger.d("POST Response status code: ${response.statusCode}");
      logger.d("POST Response body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"rawResponse": response.body};
        }
      } else {
        _throwApiException(response);
      }
    } catch (e) {
      logger.d("API POST call error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      logger.d("Making PUT request to: $uri");
      final response = await http.put(
        uri,
        headers: await getRequestHeaders(),
        body: jsonEncode(data),
      );

      logger.d("PUT Response status code: ${response.statusCode}");
      logger.d("PUT Response body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        try {
          return jsonDecode(response.body);
        } catch (e) {
          return {"rawResponse": response.body};
        }
      } else {
        _throwApiException(response);
      }
    } catch (e) {
      logger.d("API PUT call error: $e");
      rethrow;
    }
  }

  /// Parses the backend [ErrorResponse] body and throws a typed [ApiException].
  /// Falls back to [ApiException.raw] if the body is not valid JSON.
  Never _throwApiException(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      throw ApiException.fromJson(response.statusCode, body);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException.raw(response.statusCode, response.body);
    }
  }
}
