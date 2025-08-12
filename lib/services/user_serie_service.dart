import 'dart:convert';
import 'package:appventas/models/sap/sap_series.dart';
import 'package:appventas/models/user_serie.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';

class UserSeriesService {
  /// Obtener series asignadas a un usuario específico con detalles de SAP
  static Future<List<UserSerie>> getUserSeries(int userId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      // Usar el nuevo endpoint que incluye detalles de SAP
      final response = await HttpClient.get(
        '${ApiService.baseUrl}/users/$userId/series/details',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'] ?? [];
        
        // Filtrar elementos null y mapear solo elementos válidos
        return data
            .where((json) => json != null)
            .map((json) => UserSerie.fromJson(json as Map<String, dynamic>))
            .where((userSerie) => userSerie.id > 0) // Filtrar series inválidas
            .toList();
      } else if (response.statusCode == 404) {
        // Usuario no tiene series asignadas
        return <UserSerie>[];
      } else {
        throw Exception('Error al obtener series del usuario: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener series básicas sin detalles SAP (más rápido)
  static Future<List<UserSerie>> getUserSeriesBasic(int userId) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/users/$userId/series',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => UserSerie.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Error al obtener series del usuario: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Asignar una serie a un usuario
  static Future<UserSerie> assignSeries({
    required int userId,
    required String seriesId,
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final requestBody = {
        'idUsuario': userId,
        'idSerie': seriesId,
      };

      final response = await HttpClient.post(
        '${ApiService.baseUrl}/UserSeries',
        token: token,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return UserSerie.fromJson(jsonResponse['data']);
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Error al asignar serie');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener todas las series disponibles en SAP para un tipo de documento
  static Future<List<SapSeries>> getAvailableSeries({int objectCode = 17}) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/series/available?objectCode=$objectCode',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => SapSeries.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener series disponibles: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}
