class HealthMetricsRequest {
  final String firebaseUid;
  final int heightFeet;
  final int heightInches;
  final double weightKg;
  final String goal;

  HealthMetricsRequest({
    required this.firebaseUid,
    required this.heightFeet,
    required this.heightInches,
    required this.weightKg,
    required this.goal,
  });

  Map<String, dynamic> toJson() {
    return {
      'firebase_uid': firebaseUid,
      'height_feet': heightFeet,
      'height_inches': heightInches,
      'weight_kg': weightKg,
      'goal': goal,
    };
  }
}
