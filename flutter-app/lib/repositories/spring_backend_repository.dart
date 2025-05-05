import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/repositories/api_client.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:read_the_label/repositories/ai_repository_interface.dart';

class SpringBackendRepository implements AiRepositoryInterface {
  final ApiClient _apiClient;

  SpringBackendRepository(this._apiClient);

  @override
  Future<ProductAnalysisResponse> analyzeProductImages(
      File frontImage, File labelImage) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('${_apiClient.baseUrl}/ai/analyze/product'));

      // Add auth header if available
      final token = await _apiClient.getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add files
      request.files.add(
          await http.MultipartFile.fromPath('frontImage', frontImage.path));
      request.files.add(
          await http.MultipartFile.fromPath('labelImage', labelImage.path));

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Debug the raw response
      print("Raw response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check response structure
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          // Convert data to ProductAnalysisResponse
          return ProductAnalysisResponse.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              'Invalid response format: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to analyze images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing product images: $e');
    }
  }

  @override
  Future<FoodAnalysisResponse> analyzeFoodImage(File imageFile) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('${_apiClient.baseUrl}/ai/analyze/image'));

      // Add auth header if available
      final token = await _apiClient.getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Debug the raw response
      print("Raw response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check response structure
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          // Convert data to FoodAnalysisResponse
          return FoodAnalysisResponse.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              'Invalid response format: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to analyze image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing food image: $e');
    }
  }

  @override
  Future<FoodAnalysisResponse> analyzeFoodDescription(
      String description) async {
    try {
      // Create request
      var uri = Uri.parse('${_apiClient.baseUrl}/ai/analyze/description');

      // Add auth header if available
      final token = await _apiClient.getAuthToken();
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Send request with JSON body
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({'description': description}),
      );

      // Debug the raw response
      print("Raw response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check response structure
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          // Convert data to FoodAnalysisResponse
          return FoodAnalysisResponse.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              'Invalid response format: ${jsonResponse['message'] ?? "Unknown error"}');
        }
      } else {
        throw Exception(
            'Failed to analyze description: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing food description: $e');
    }
  }
}
