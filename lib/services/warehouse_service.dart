// lib/services/warehouse_service.dart
import 'dart:convert';
import 'package:appventas/models/warehouse/warehouse.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';

class WarehouseService {
  /// Obtener todos los almacenes activos
  static Future<List<Warehouse>> getAllWarehouses() async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/Warehouse',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Warehouse.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener almacenes: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Buscar almacenes con paginación
  static Future<WarehouseSearchResponse> searchWarehouses({
    String searchTerm = '',
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final queryParams = {
        'searchTerm': searchTerm,
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
      };

      final uri = Uri.parse('${ApiService.baseUrl}/Warehouse/search').replace(
        queryParameters: queryParams,
      );

      final response = await HttpClient.get(uri.toString(), token: token);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return WarehouseSearchResponse.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Error al buscar almacenes: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener almacén por código
  static Future<Warehouse> getWarehouseByCode(String whsCode) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/Warehouse/$whsCode',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Warehouse.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Almacén no encontrado');
      } else {
        throw Exception('Error al obtener almacén: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Buscar almacenes para autocomplete/selector
  static Future<List<Warehouse>> searchWarehousesForSelector(String searchTerm) async {
    try {
      final response = await searchWarehouses(
        searchTerm: searchTerm,
        pageSize: 50, // Tamaño más grande para selector
        pageNumber: 1,
      );
      return response.warehouses;
    } catch (e) {
      throw Exception('Error buscando almacenes: $e');
    }
  }
}