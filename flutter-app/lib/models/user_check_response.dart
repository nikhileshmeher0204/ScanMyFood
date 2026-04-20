class UserCheckResponse {
  final bool isNewUser;

  UserCheckResponse({required this.isNewUser});

  factory UserCheckResponse.fromJson(Map<String, dynamic> json) {
    return UserCheckResponse(
      isNewUser: json['new_user'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new_user': isNewUser,
    };
  }
}
