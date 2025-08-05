import 'dart:convert';

import 'package:appventas/models/sales_person.dart';
import 'package:appventas/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';
  static const _salesPersonKey = 'sales_person_data';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> saveUser(User user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final userString = await _storage.read(key: _userKey);
    if (userString != null) {
      return User.fromJson(jsonDecode(userString));
    }
    return null;
  }

  // Métodos para SalesPerson
  static Future<void> saveSalesPerson(SalesPerson salesPerson) async {
    await _storage.write(key: _salesPersonKey, value: jsonEncode(salesPerson.toJson()));
  }

  static Future<SalesPerson?> getSalesPerson() async {
    final salesPersonString = await _storage.read(key: _salesPersonKey);
    if(salesPersonString != null){
      try {
        return SalesPerson.fromJson(jsonDecode(salesPersonString));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    return token != null && user != null;
  }
}