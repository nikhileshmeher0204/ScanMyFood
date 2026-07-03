import 'dart:async';
import 'package:read_the_label/repositories/api_client.dart';

class ToolExecutionClient {
  final ApiClient _apiClient;
  final _mealLoggedController = StreamController<void>.broadcast();

  Stream<void> get onMealLogged => _mealLoggedController.stream;

  ToolExecutionClient(this._apiClient);

  /// Execute a tool on the Spring Boot backend
  /// POST /api/tools/{toolName}/execute
  Future<Map<String, Object?>> execute(
    String toolName,
    Map<String, dynamic> args,
  ) async {
    final response = await _apiClient.post(
      '/tools/$toolName/execute',
      args,
    );
    // The response has the shape ApiResponse<Map<String, Object>>
    // where data is the map we returned
    if (response['status'] == 'success' && response['data'] != null) {
      final data = Map<String, Object?>.from(response['data'] as Map);
      if (toolName == 'saveScannedFoodIntake' && data['success'] == true) {
        _mealLoggedController.add(null);
      }
      return data;
    }
    return {};
  }

  void dispose() {
    _mealLoggedController.close();
  }
}
