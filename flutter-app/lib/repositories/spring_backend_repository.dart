import 'package:read_the_label/repositories/api_client.dart';

class SpringBackendRepository {
  final ApiClient _apiClient;

  SpringBackendRepository(this._apiClient);

  // Check if backend is reachable
  Future<bool> isBackendReachable() async {
    try {
      // Add logging to debug the response
      print("Attempting to connect to backend...");
      final response = await _apiClient.get('/health');
      print("Backend response: $response");

      // More flexible check for success
      return response != null; // Basic check that we got any response
    } catch (e) {
      print("Backend connection error: $e");
      return false;
    }
  }

  // Add more repository methods as needed
}
