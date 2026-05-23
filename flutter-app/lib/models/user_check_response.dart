class UserCheckResponse {
  final bool isNewUser;
  final bool isOnboardingComplete;

  UserCheckResponse(
      {required this.isNewUser, required this.isOnboardingComplete});

  factory UserCheckResponse.fromJson(Map<String, dynamic> json) {
    return UserCheckResponse(
      isNewUser: json['new_user'],
      isOnboardingComplete: json['onboarding_complete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_user': isNewUser,
      'onboarding_complete': isOnboardingComplete,
    };
  }
}
