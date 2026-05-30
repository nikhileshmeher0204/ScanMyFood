import 'package:read_the_label/models/health_condition.dart';

class UserProfile {
  final String userId;
  final String email;
  final String displayName;
  final bool isOnboardingComplete;
  final String? dietaryPreference;
  final String? country;
  final int? heightFeet;
  final int? heightInches;
  final double? weightKg;
  final String? goal;
  final double? bmi;
  final String? bmiCategory;
  final List<HealthCondition> healthConditions;

  UserProfile({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.isOnboardingComplete,
    this.dietaryPreference,
    this.country,
    this.heightFeet,
    this.heightInches,
    this.weightKg,
    this.goal,
    this.bmi,
    this.bmiCategory,
    required this.healthConditions,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var healthConditionsJson = json['healthConditions'] as List? ?? [];
    List<HealthCondition> healthConditionsList = healthConditionsJson
        .map((e) => HealthCondition.fromJson(e as Map<String, dynamic>))
        .toList();

    return UserProfile(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      isOnboardingComplete: json['onboardingComplete'] ?? false,
      dietaryPreference: json['dietaryPreference'],
      country: json['country'],
      heightFeet: json['heightFeet'],
      heightInches: json['heightInches'],
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      goal: json['goal'],
      bmi: (json['bmi'] as num?)?.toDouble(),
      bmiCategory: json['bmiCategory'],
      healthConditions: healthConditionsList,
    );
  }
}
