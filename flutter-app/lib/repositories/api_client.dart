import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  // Helper method for GET requests
  Future<dynamic> get(String endpoint) async {
    try {
      final token = await getAuthToken();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

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
      print("API call error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await getAuthToken();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      print("POST Response status code: ${response.statusCode}");
      print("POST Response body: ${response.body}");

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
      print("API POST call error: $e");
      rethrow;
    }
  }

  // Add more methods for PUT, DELETE, etc. as needed
}
