class OnboardingRequest {
  final String userId;

  OnboardingRequest({
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {'user_id': userId};
  }
}
