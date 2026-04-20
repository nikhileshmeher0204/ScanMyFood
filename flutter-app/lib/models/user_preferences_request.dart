class UserPreferencesRequest {
  final String firebaseUid;
  final String dietaryPreference;
  final String country;

  UserPreferencesRequest({
    required this.firebaseUid,
    required this.dietaryPreference,
    required this.country,
  });

  Map<String, dynamic> toJson() {
    return {
      'firebase_uid': firebaseUid,
      'dietary_preference': dietaryPreference,
      'country': country,
    };
  }
}
