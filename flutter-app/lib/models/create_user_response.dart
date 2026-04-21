class CreateUserResponse {
  final String userId;
  final bool created;

  CreateUserResponse({required this.userId, required this.created});

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      userId: json['userId'] ?? '',
      created: json['created'] ?? false,
    );
  }
}
