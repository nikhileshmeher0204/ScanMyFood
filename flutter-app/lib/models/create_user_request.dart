class CreateUserRequest {
  final String userId;
  final String email;
  final String displayName;

  CreateUserRequest({
    required this.userId,
    required this.email,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'display_name': displayName,
    };
  }
}
