class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
      errors: json['errors']?.cast<String>(),
    );
  }
}