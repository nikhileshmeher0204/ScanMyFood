class HealthMetricsRequest {
  final String userId;
  final int heightFeet;
  final int heightInches;
  final double weightKg;
  final String goal;

  HealthMetricsRequest({
    required this.userId,
    required this.heightFeet,
    required this.heightInches,
    required this.weightKg,
    required this.goal,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'height_feet': heightFeet,
      'height_inches': heightInches,
      'weight_kg': weightKg,
      'goal': goal,
    };
  }
}
