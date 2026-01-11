import 'dart:convert';
import 'dart:io';
import 'package:read_the_label/core/constants/response_code_constants.dart';
import 'package:read_the_label/main.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/product_analysis_response.dart';
import 'package:read_the_label/models/save_intake_output.dart';
import 'package:read_the_label/models/save_scanned_food_input.dart';
import 'package:read_the_label/models/save_scanned_label_input.dart';
import 'package:read_the_label/models/user_intake_output.dart';
import 'package:read_the_label/repositories/api_client.dart';
import 'package:read_the_label/repositories/intake_repository_interface.dart';

class IntakeRepository implements IntakeRepositoryInterface {
  final ApiClient _apiClient;

  IntakeRepository(this._apiClient);

  @override
  Future<SaveIntakeOutput> saveScannedFood(String userId, File? foodImage,
      FoodAnalysisResponse? foodAnalysis) async {
    try {
      SaveScannedFoodInput saveScannedFoodInput = SaveScannedFoodInput(
        userId: userId,
        foodAnalysisResponse: foodAnalysis!,
      );
      var request = http.MultipartRequest(
          'POST', Uri.parse('${_apiClient.baseUrl}/user/save/scannedFood'));

      final token = await _apiClient.getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(
        http.MultipartFile.fromString(
          'saveScannedFoodInput',
          jsonEncode(saveScannedFoodInput.toJson()),
          contentType: MediaType('application', 'json'),
          filename: 'saveScannedFoodInput.json',
        ),
      );
      if (foodImage != null) {
        request.files.add(
            await http.MultipartFile.fromPath('foodImage', foodImage.path));
      }
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check response structure
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['response_code'] ==
                ResponseCodeConstants.scannedFoodSaved &&
            jsonResponse['data'] != null) {
          logger.i("Scanned food saved successfully.");
          return SaveIntakeOutput.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              'Invalid response format: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to analyze images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving scanned food: $e');
    }
  }

  @override
  Future<SaveIntakeOutput> saveScannedLabel(String userId, File? productImage,
      ProductAnalysisResponse? productAnalysis) async {
    try {
      SaveScannedLabelInput saveScannedLabelInput = SaveScannedLabelInput(
        userId: userId,
        productAnalysisResponse: productAnalysis!,
      );
      var request = http.MultipartRequest(
          'POST', Uri.parse('${_apiClient.baseUrl}/user/save/scannedLabel'));

      final token = await _apiClient.getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.files.add(
        http.MultipartFile.fromString(
          'saveScannedLabelInput',
          jsonEncode(saveScannedLabelInput.toJson()),
          contentType: MediaType('application', 'json'),
          filename: 'saveScannedLabelInput.json',
        ),
      );

      request.files.add(await http.MultipartFile.fromPath(
          'productImage', productImage!.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check response structure
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['response_code'] ==
                ResponseCodeConstants.scannedLabelSaved &&
            jsonResponse['data'] != null) {
          logger.i("Scanned label saved successfully.");
          return SaveIntakeOutput.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              'Invalid response format: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to analyze images: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving scanned label: $e');
    }
  }

  @override
  Future<UserIntakeOutput> getDailyIntake(String userId, DateTime date) async {
    try {
      final formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final uri = Uri.parse('${_apiClient.baseUrl}/user/intake').replace(
        queryParameters: {
          'userId': userId,
          'date': formattedDate,
        },
      );

      final token = await _apiClient.getAuthToken();
      final headers = <String, String>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(uri, headers: headers);
      print("Raw response: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check response structure
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['response_code'] ==
                ResponseCodeConstants.dailyIntakeFetched &&
            jsonResponse['data'] != null) {
          // Convert data to FoodAnalysisResponse
          return UserIntakeOutput.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
              'Invalid response format: ${jsonResponse['message'] ?? "Unknown error"}');
        }
      } else {
        throw Exception(
            'Failed to analyze description: ${response.statusCode}');
      }
    } catch (exception) {
      throw Exception('Error getting daily intake: $exception');
    }
  }
}
