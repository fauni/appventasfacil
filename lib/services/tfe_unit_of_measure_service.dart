import 'dart:convert';
import 'package:appventas/models/item/tfe_unit_of_measure.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';

class TfeUnitOfMeasureService {
  /// Obtener todas las unidades de medida de venta TFE
  static Future<List<TfeUnitOfMeasure>> getTfeUnitsOfMeasure() async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/TfeUnitOfMeasure',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => TfeUnitOfMeasure.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('No se encontraron unidades de medida de venta TFE');
      } else {
        throw Exception('Error al obtener unidades de medida TFE: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}