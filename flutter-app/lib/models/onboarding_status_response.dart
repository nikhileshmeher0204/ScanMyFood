class OnboardingStatusResponse {
  final bool isOnboardingComplete;

  OnboardingStatusResponse({required this.isOnboardingComplete});

  factory OnboardingStatusResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingStatusResponse(
      isOnboardingComplete: json['onboarding_complete'] ?? false,
    );
  }
}
