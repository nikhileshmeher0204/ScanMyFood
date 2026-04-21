class CreateUserRequest {
  final String firebaseUid;
  final String email;
  final String displayName;

  CreateUserRequest({
    required this.firebaseUid,
    required this.email,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'firebase_uid': firebaseUid,
      'email': email,
      'display_name': displayName,
    };
  }
}
