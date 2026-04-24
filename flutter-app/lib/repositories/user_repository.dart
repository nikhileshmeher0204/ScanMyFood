import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/create_user_request.dart';
import 'package:read_the_label/models/health_metrics_request.dart';
import 'package:read_the_label/models/onboarding_request.dart';
import 'package:read_the_label/models/onboarding_status_response.dart';
import 'package:read_the_label/models/user_check_response.dart';
import 'package:read_the_label/models/user_preferences_request.dart';
import 'package:read_the_label/models/health_condition.dart';
import 'package:read_the_label/models/save_user_conditions_request.dart';
import 'package:read_the_label/repositories/api_client.dart';
import 'package:read_the_label/repositories/user_repository_interface.dart';

class UserRepository implements UserRepositoryInterface {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  @override
  Future<UserCheckResponse> isNewUser() async {
    logger.d('Checking if user is new...');

    final uid = _apiClient.getCurrentUid();
    if (uid == null) {
      logger.w('isNewUser called with no authenticated user; treating as new.');
      return UserCheckResponse(isNewUser: true, isOnboardingComplete: false);
    }

    try {
      final response = await _apiClient.get('/users/user');
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException(
            'Unexpected response shape for /users/user');
      }
      final result = UserCheckResponse.fromJson(data);
      logger.d(
          'isNewUser=${result.isNewUser}, onboardingComplete=${result.isOnboardingComplete}');
      return result;
    } on FormatException catch (e, st) {
      logger.e('Failed to parse UserCheckResponse', e, st);
      rethrow;
    } catch (e, st) {
      logger.e('Failed to check if user is new', e, st);
      rethrow;
    }
  }

  @override
  Future<void> completeOnboarding({
    required String firebaseUid,
  }) async {
    logger.d('Completing onboarding...');
    try {
      final request = OnboardingRequest(
        firebaseUid: firebaseUid,
      );
      await _apiClient.post('/users/complete-onboarding', request.toJson());
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
    final request = UserPreferencesRequest(
      firebaseUid: firebaseUid,
      dietaryPreference: dietaryPreference,
      country: country,
    );
    await _apiClient.put('/users/preferences', request.toJson());
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
    final request = HealthMetricsRequest(
      firebaseUid: firebaseUid,
      heightFeet: heightFeet,
      heightInches: heightInches,
      weightKg: weightKg,
      goal: goal,
    );
    await _apiClient.put('/users/health-metrics', request.toJson());
  }

  @override
  Future<void> createUser(
      String firebaseUid, String email, String displayName) async {
    logger.d('Creating user...');
    final request = CreateUserRequest(
      firebaseUid: firebaseUid,
      email: email,
      displayName: displayName,
    );
    await _apiClient.post('/users/create-user', request.toJson());
  }

  @override
  Future<List<HealthCondition>> getHealthConditions() async {
    logger.d('Fetching health conditions...');
    try {
      final response = await _apiClient.get('/health-conditions');
      if (response is Map && response.containsKey('data')) {
        final List<dynamic> data = response['data'];
        return data.map((json) => HealthCondition.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      logger.e('Failed to fetch health conditions: $e');
      return [];
    }
  }

  @override
  Future<void> saveUserHealthConditions({
    required String firebaseUid,
    required List<String> conditionNames,
  }) async {
    logger.d('Saving user health conditions...');
    final request = SaveUserConditionsRequest(
      firebaseUid: firebaseUid,
      conditionNames: conditionNames,
    );
    await _apiClient.put('/users/health-conditions', request.toJson());
  }
}
