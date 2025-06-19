class AuthResponse {
  final int code;
  final dynamic data;
  final String message;

  AuthResponse({required this.code, required this.data, required this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      code: json['code'],
      data: json['data'],
      message: json['message'],
    );
  }
}
