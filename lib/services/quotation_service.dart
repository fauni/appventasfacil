import 'dart:convert';
import 'package:appventas/models/quotation/sales_quotation_dto.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';
import 'package:http/http.dart' as http;

import 'package:appventas/models/quotation/sales_quotation.dart';
import 'package:appventas/services/api_service.dart';


class QuotationService {
  static Future<List<SalesQuotation>> getQuotations(String token) async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/SalesQuotation',
        token: token,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => SalesQuotation.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar cotizaciones: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  static Future<String> createQuotation(SalesQuotationDto quotationDto) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.post(
        '${ApiService.baseUrl}/SalesQuotation',
        body: quotationDto.toJson(),
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? 'Cotización creada exitosamente';
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Error al crear cotización');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}