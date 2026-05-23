class UserPreferencesRequest {
  final String userId;
  final String dietaryPreference;
  final String country;

  UserPreferencesRequest({
    required this.userId,
    required this.dietaryPreference,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'dietary_preference': dietaryPreference,
      'country': country,
    };
  }
}
