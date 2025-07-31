import 'dart:convert';

import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';

class UnitOfMeasureService {
  // Obtener unidades de medida por código de item
  static Future<List<UnitOfMeasure>> getUnitOfMeasuresByItem(String itemCode) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/UnitOfMeasure/item/$itemCode',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => UnitOfMeasure.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('No se encontraron unidades de medida para el item $itemCode');
      } else {
        throw Exception('Error al obtener unidades de medida: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}