import 'package:read_the_label/models/health_condition.dart';
import 'package:read_the_label/models/user_check_response.dart';
import 'package:read_the_label/models/user_profile.dart';

abstract class UserRepositoryInterface {
  /// Checks if the current user is new.
  /// Returns a [UserCheckResponse] containing [isNewUser] and [isOnboardingComplete] flags.
  Future<UserCheckResponse> isNewUser();


  /// Creates a user record on the backend.
  ///
  /// Parameters:
  /// - userId: The user's unique ID (e.g. Firebase UID)
  /// - email: The user's email
  /// - displayName: The user's display name
  Future<void> createUser(String userId, String email, String displayName);

  /// Completes the onboarding process.
  ///
  /// Parameters:
  /// - userId: The user's unique ID
  Future<void> completeOnboarding({required String userId});

  /// Saves the user's dietary preferences and country.
  ///
  /// Parameters:
  /// - userId: The user's unique ID
  /// - dietaryPreference: The user's dietary preference
  /// - country: The user's country
  Future<void> saveUserPreferences({
    required String userId,
    required String dietaryPreference,
    required String country,
  });

  /// Saves the user's health metrics.
  ///
  /// Parameters:
  /// - userId: The user's unique ID
  /// - heightFeet: Height in feet
  /// - heightInches: Height in inches
  /// - weightKg: Weight in kilograms
  /// - goal: Health goal
  Future<void> saveHealthMetrics({
    required String userId,
    required int heightFeet,
    required int heightInches,
    required double weightKg,
    required String goal,
  });

  /// Fetches the master list of health conditions.
  Future<List<HealthCondition>> getHealthConditions();

  /// Saves the user's selected health conditions.
  ///
  /// Parameters:
  /// - userId: The user's unique ID
  /// - conditionNames: List of selected condition names
  Future<void> saveUserHealthConditions({
    required String userId,
    required List<String> conditionNames,
  });

  /// Fetches the complete user profile including health conditions and BMI.
  Future<UserProfile> getUserProfile();
}
