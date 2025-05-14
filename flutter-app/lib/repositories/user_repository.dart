import 'package:read_the_label/main.dart';
import 'package:read_the_label/repositories/api_client.dart';
import 'package:read_the_label/repositories/user_repository_interface.dart';

class UserRepository implements UserRepositoryInterface {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  @override
  Future<bool> isNewUser() async {
    logger.d('Checking if user is new...');
    try {
      final token = await _apiClient.getAuthToken();
      final uid = _apiClient.getCurrentUid();
      if (token == null || uid == null) return true;

      logger.d('User ID: $uid');
      final response = await _apiClient.get('/users/check/new-user/$uid');
      logger.d('Response: $response');
      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is Map && data.containsKey('isNewUser')) {
          return data['isNewUser'] ?? true;
        }
      }
      logger.w('Could not parse isNewUser from response');
      return true;
    } catch (e) {
      logger.d('Error checking if user is new: $e');
      return true; // Default to treating as new user on error
    }
  }

  @override
  Future<bool> isOnboardingComplete({required String firebaseUid}) async {
    try {
      final response =
          await _apiClient.get('/users/check/onboarding-status/$firebaseUid');
      logger.d('Response: $response');

      if (response is Map && response.containsKey('data')) {
        final data = response['data'];
        if (data is Map && data.containsKey('isOnboardingComplete')) {
          return data['isOnboardingComplete'] ?? true;
        }
      }
      logger.w('Could not parse isOnboardingComplete from response');
      return false;
    } catch (e) {
      logger.d('Error checking if user\'s onboarinng is completed: $e');
      return false;
    }
  }

  @override
  Future<void> completeOnboarding({
    required String firebaseUid,
    required String dietaryPreference,
    required String country,
    required int heightFeet,
    required int heightInches,
    required double weightKg,
    required String goal,
  }) async {
    logger.d('Completing onboarding...');
    try {
      await _apiClient.post('/users/complete-onboarding', {
        'firebaseUid': firebaseUid,
        'preferences': {
          'dietaryPreference': dietaryPreference,
          'country': country,
        },
        'healthMetrics': {
          'heightFeet': heightFeet,
          'heightInches': heightInches,
          'weightKg': weightKg,
          'goal': goal,
        }
      });
      logger.d('Onboarding completed successfully');
    } catch (e) {
      logger.e('Failed to complete onboarding: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveUserPreferences({
    required String firebaseUid,
    required String dietaryPreference,
    required String country,
  }) async {
    logger.d('Saving user preferences...');
    await _apiClient.post('/users/preferences', {
      'firebaseUid': firebaseUid,
      'dietaryPreference': dietaryPreference,
      'country': country,
    });
  }

  @override
  Future<void> saveHealthMetrics({
    required String firebaseUid,
    required int heightFeet,
    required int heightInches,
    required double weightKg,
    required String goal,
  }) async {
    logger.d('Saving health metrics...');
    await _apiClient.post('/users/health-metrics', {
      'firebaseUid': firebaseUid,
      'heightFeet': heightFeet,
      'heightInches': heightInches,
      'weightKg': weightKg,
      'goal': goal,
    });
  }

  @override
  Future<void> createUser(
      String firebaseUid, String email, String displayName) async {
    logger.d('Creating user...');
    await _apiClient.post('/users/create-user', {
      'firebaseUid': firebaseUid,
      'email': email,
      'displayName': displayName,
    });
  }
}
