import 'dart:convert';
import 'dart:io';
import 'package:read_the_label/main.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:read_the_label/models/food_analysis_response.dart';
import 'package:read_the_label/models/save_scanned_food_input.dart';
import 'package:read_the_label/repositories/api_client.dart';
import 'package:read_the_label/repositories/intake_repository_interface.dart';

class IntakeRepository implements IntakeRepositoryInterface {
  final ApiClient _apiClient;

  IntakeRepository(this._apiClient);

  @override
  Future<void> saveScannedFood(String userId, File? foodImage,
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
          jsonEncode(saveScannedFoodInput?.toJson()),
          contentType: MediaType('application', 'json'),
        ),
      );

      request.files
          .add(await http.MultipartFile.fromPath('foodImage', foodImage!.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check response structure
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          // success
          logger.i("Scanned food saved successfully.");
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
}
