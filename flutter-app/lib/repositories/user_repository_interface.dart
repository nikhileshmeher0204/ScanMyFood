abstract class UserRepositoryInterface {
  /// Checks if the current user is new
  /// Returns true if user is new, false otherwise
  Future<bool> isNewUser();

  /// Checks if the current user is new
  /// Returns true if user is new, false otherwise
  ///
  /// Parameters:
  /// - firebaseUid: The user's Firebase UID
  /// - email: The user's email
  /// - displayName: The user's display name
  Future<void> createUser(String firebaseUid, String email, String displayName);

  /// Checks if the onboarding process is complete
  ///
  /// Parameters:
  /// - firebaseUid: The user's Firebase UID
  Future<bool> isOnboardingComplete({
    required String firebaseUid,
  });

  /// Completes the onboarding process
  ///
  /// Parameters:
  /// - firebaseUid: The user's Firebase UID
  /// - dietaryPreference: The user's dietary preference
  /// - country: The user's country
  /// - heightFeet: Height in feet
  /// - heightInches: Height in inches
  /// - weightKg: Weight in kilograms
  /// - goal: Health goal
  /// Returns a Future that completes when the onboarding is complete
  Future<void> completeOnboarding({
    required String firebaseUid,
    required String dietaryPreference,
    required String country,
    required int heightFeet,
    required int heightInches,
    required double weightKg,
    required String goal,
  });

  /// Saves the user's dietary preferences and country
  ///
  /// Parameters:
  /// - dietaryPreference: The user's dietary preference
  /// - country: The user's country
  Future<void> saveUserPreferences({
    required String firebaseUid,
    required String dietaryPreference,
    required String country,
  });

  /// Saves the user's health metrics
  ///
  /// Parameters:
  /// - heightFeet: Height in feet
  /// - heightInches: Height in inches
  /// - weightKg: Weight in kilograms
  /// - goal: Health goal
  Future<void> saveHealthMetrics({
    required String firebaseUid,
    required int heightFeet,
    required int heightInches,
    required double weightKg,
    required String goal,
  });
}
