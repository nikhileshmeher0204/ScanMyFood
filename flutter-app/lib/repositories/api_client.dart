import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:read_the_label/main.dart';

class ApiClient {
  final String baseUrl;

  // For local development
  ApiClient({this.baseUrl = 'http://10.0.2.2:8080/api'});

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
  String? getCurrentUid() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Helper method for GET requests
  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      logger.d("Making GET request to: $uri");

      final token = await getAuthToken();
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15)); // Add timeout

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
        throw Exception('Failed with status code: ${response.statusCode}');
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
      final token = await getAuthToken();

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
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
        throw Exception('POST failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.d("API POST call error: $e");
      rethrow;
    }
  }
}
