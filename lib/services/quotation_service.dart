import 'dart:convert';
import 'package:appventas/models/sales_quotation_dto.dart';
import 'package:http/http.dart' as http;

import 'package:appventas/models/sales_quotation.dart';
import 'package:appventas/services/api_service.dart';


class QuotationService {
  static Future<List<SalesQuotation>> getQuotations(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/SalesQuotation'),
        headers: ApiService.getHeaders(token: token),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => SalesQuotation.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar cotizaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<String> createQuotation(SalesQuotationDto quotationDto, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/SalesQuotation'),
        headers: ApiService.getHeaders(token: token),
        body: jsonEncode(quotationDto.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? 'Cotización creada exitosamente';
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to create quotation');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}