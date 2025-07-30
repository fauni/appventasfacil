import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:appventas/services/storage_service.dart';
import 'package:appventas/blocs/auth/auth_bloc.dart';
import 'package:appventas/blocs/auth/auth_event.dart';

class HttpClient {
  static AuthBloc? _authBloc;
  
  static void setAuthBloc(AuthBloc authBloc) {
    _authBloc = authBloc;
  }

  /// Método GET con manejo automático de 401
  static Future<http.Response> get(String url, {String? token}) async {
    final headers = await _buildHeaders(token);
    
    final response = await http.get(Uri.parse(url), headers: headers);
    
    if (response.statusCode == 401) {
      await _handle401();
      throw UnauthorizedException('Sesión expirada');
    }
    
    return response;
  }

  /// Método POST con manejo automático de 401
  static Future<http.Response> post(String url, {Object? body, String? token}) async {
    final headers = await _buildHeaders(token);
    
    final response = await http.post(
      Uri.parse(url), 
      headers: headers, 
      body: body is String ? body : jsonEncode(body)
    );
    
    if (response.statusCode == 401) {
      await _handle401();
      throw UnauthorizedException('Sesión expirada');
    }
    
    return response;
  }

  /// Método PUT con manejo automático de 401
  static Future<http.Response> put(String url, {Object? body, String? token}) async {
    final headers = await _buildHeaders(token);
    
    final response = await http.put(
      Uri.parse(url), 
      headers: headers, 
      body: body is String ? body : jsonEncode(body)
    );
    
    if (response.statusCode == 401) {
      await _handle401();
      throw UnauthorizedException('Sesión expirada');
    }
    
    return response;
  }

  /// Método DELETE con manejo automático de 401
  static Future<http.Response> delete(String url, {String? token}) async {
    final headers = await _buildHeaders(token);
    
    final response = await http.delete(Uri.parse(url), headers: headers);
    
    if (response.statusCode == 401) {
      await _handle401();
      throw UnauthorizedException('Sesión expirada');
    }
    
    return response;
  }

  /// Construir headers con token
  static Future<Map<String, String>> _buildHeaders(String? token) async {
    final authToken = token ?? await StorageService.getToken();
    
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  /// Manejar respuesta 401 - Logout inmediato
  static Future<void> _handle401() async {
    print('🚨 401 Unauthorized - Redirigiendo a login...');
    
    // Limpiar almacenamiento local
    await StorageService.clearAll();
    
    // Disparar logout en AuthBloc si está disponible
    if (_authBloc != null) {
      _authBloc!.add(AuthLogoutRequested());
    }
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  
  @override
  String toString() => 'UnauthorizedException: $message';
}