class OnboardingRequest {
  final String firebaseUid;

  OnboardingRequest({
    required this.firebaseUid,
  });

  Map<String, dynamic> toJson() {
    return {'firebase_uid': firebaseUid};
  }
}
