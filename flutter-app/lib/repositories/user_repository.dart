import 'package:read_the_label/main.dart';
import 'package:read_the_label/models/create_user_request.dart';
import 'package:read_the_label/models/health_metrics_request.dart';
import 'package:read_the_label/models/onboarding_request.dart';
import 'package:read_the_label/models/user_check_response.dart';
import 'package:read_the_label/models/user_preferences_request.dart';
import 'package:read_the_label/models/health_condition.dart';
import 'package:read_the_label/models/save_user_conditions_request.dart';
import 'package:read_the_label/models/user_profile.dart';
import 'package:read_the_label/repositories/api_client.dart';
import 'package:read_the_label/repositories/user_repository_interface.dart';
import 'package:read_the_label/services/local_database_service.dart';
import 'package:read_the_label/models/cached_user_profile_record.dart';

class UserRepository implements UserRepositoryInterface {
  final ApiClient _apiClient;

  UserRepository(this._apiClient);

  @override
  Future<UserCheckResponse> isNewUser() async {
    logger.d('Checking if user is new...');

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
    required String userId,
  }) async {
    logger.d('Completing onboarding...');
    try {
      final request = OnboardingRequest(userId: userId);
      await _apiClient.post('/users/complete-onboarding', request.toJson());
      logger.d('Onboarding completed successfully');
      await _clearProfileCache();
    } catch (e) {
      logger.e('Failed to complete onboarding: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveUserPreferences({
    required String userId,
    required String dietaryPreference,
    required String country,
  }) async {
    logger.d('Saving user preferences...');
    final request = UserPreferencesRequest(
      userId: userId,
      dietaryPreference: dietaryPreference,
      country: country,
    );
    await _apiClient.put('/users/preferences', request.toJson());
    await _clearProfileCache();
  }

  @override
  Future<void> saveHealthMetrics({
    required String userId,
    required int heightFeet,
    required int heightInches,
    required double weightKg,
    required String goal,
  }) async {
    logger.d('Saving health metrics...');
    final request = HealthMetricsRequest(
      userId: userId,
      heightFeet: heightFeet,
      heightInches: heightInches,
      weightKg: weightKg,
      goal: goal,
    );
    await _apiClient.put('/users/health-metrics', request.toJson());
    await _clearProfileCache();
  }

  @override
  Future<void> createUser(
      String userId, String email, String displayName) async {
    logger.d('Creating user...');
    final request = CreateUserRequest(
      userId: userId,
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
    required String userId,
    required List<String> conditionNames,
  }) async {
    logger.d('Saving user health conditions...');
    final request = SaveUserConditionsRequest(
      userId: userId,
      conditionNames: conditionNames,
    );
    await _apiClient.put('/users/health-conditions', request.toJson());
    await _clearProfileCache();
  }

  Future<void> _clearProfileCache() async {
    try {
      final userId = _apiClient.getCurrentUid();
      await LocalDatabaseService.instance.clearUserProfile(userId);
      logger.d('Cleared user profile cache in SQLite for $userId');
    } catch (e) {
      logger.w('Failed to clear user profile cache: $e');
    }
  }

  @override
  Future<UserProfile> getUserProfile() async {
    logger.d('Fetching user profile...');
    final userId = _apiClient.getCurrentUid();

    try {
      final cachedRecord = await LocalDatabaseService.instance.getUserProfile(userId);
      if (cachedRecord != null) {
        if (!cachedRecord.isExpired) {
          logger.d('Found fresh cached user profile for $userId (TTL check passed)');
          return cachedRecord.profile;
        } else {
          logger.d('Cached user profile for $userId is expired. Re-fetching from network...');
        }
      } else {
        logger.d('No cached user profile found for $userId. Fetching from network...');
      }
    } catch (e) {
      logger.w('Failed to read user profile from cache: $e');
    }

    try {
      final response = await _apiClient.get('/users/profile');
      final data = response['data'];
      if (data is! Map<String, dynamic>) {
        throw const FormatException(
            'Unexpected response shape for /users/profile');
      }

      final profile = UserProfile.fromJson(data);

      // Save to SQLite database cache
      try {
        final record = CachedUserProfileRecord(
          userId: userId,
          profile: profile,
          cachedAt: DateTime.now(),
        );
        await LocalDatabaseService.instance.saveUserProfile(record);
        logger.d('Successfully cached user profile in SQLite for $userId');
      } catch (e) {
        logger.w('Failed to cache user profile in SQLite: $e');
      }

      return profile;
    } catch (e, st) {
      logger.e('Failed to fetch user profile', e, st);
      rethrow;
    }
  }
}
