import 'package:appventas/models/user.dart';

class LoginResponse {
  final String token;
  final User user;
  final String message;

  LoginResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['data']['token'],
      user: User.fromJson(json['data']['user']),
      message: json['message'],
    );
  }
}