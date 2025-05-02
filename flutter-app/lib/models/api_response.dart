class ApiResponse<T> {
  final String status;
  final String? message;
  final T data;

  ApiResponse({
    required this.status,
    required this.data,
    this.message,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      status: json['status'],
      message: json['message'],
      data: fromJsonT(json['data']),
    );
  }
}
