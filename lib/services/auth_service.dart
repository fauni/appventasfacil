import 'dart:convert';

import 'package:appventas/models/user.dart';
import 'package:appventas/services/api_service.dart';
import 'package:http/http.dart' as http;

import 'package:appventas/models/login_request.dart';
import 'package:appventas/models/login_response.dart';


class AuthService {
  static Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/users/login'),
        headers: ApiService.getHeaders(),
        body: jsonEncode(request.toJson())
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return LoginResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Login failed');
      }
    } catch(e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<User> createUser(User user, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/users'),
        headers: ApiService.getHeaders(token: token),
        body: jsonEncode(user.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return User.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Create user failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}