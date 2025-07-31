import 'dart:convert';

import 'package:appventas/models/item/item.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';

class ItemService {
  /// Buscar items con paginación
  static Future<ItemSearchResponse> searchItems({
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

      final uri = Uri.parse('${ApiService.baseUrl}/Item/search').replace(
        queryParameters: queryParams,
      );

      final response = await HttpClient.get(uri.toString(), token: token);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return ItemSearchResponse.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Error al buscar items: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener item por código
  static Future<Item> getItemByCode(String itemCode) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/Item/$itemCode',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Item.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Item no encontrado');
      } else {
        throw Exception('Error al obtener item: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Autocompletado de items
  static Future<List<ItemAutocomplete>> getItemsAutocomplete(String term) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/Item/autocomplete').replace(
        queryParameters: {'term': term},
      );

      final response = await HttpClient.get(uri.toString(), token: token);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => ItemAutocomplete.fromJson(json)).toList();
      } else {
        throw Exception('Error en autocompletado de items: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}