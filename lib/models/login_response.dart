import 'package:appventas/models/sales_person.dart';
import 'package:appventas/models/user.dart';

class LoginResponse {
  final String token;
  final User user;
  final SalesPerson? salesPerson;
  final String message;

  LoginResponse({
    required this.token,
    required this.user,
    this.salesPerson,
    required this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['data']['token'],
      user: User.fromJson(json['data']['user']),
      salesPerson: json['data']['salesPerson'] != null 
          ? SalesPerson.fromJson(json['data']['salesPerson'])
          : null,
      message: json['message'],
    );
  }
}