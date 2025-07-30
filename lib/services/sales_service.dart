import 'dart:convert';

import 'package:appventas/services/api_service.dart';
import 'package:http/http.dart' as http;

class SalesService {
   static Future<List<dynamic>> getSalesOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/sales'),
        headers: ApiService.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      } else {
        throw Exception('Failed to load sales orders');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> createSaleFromQuotation(
      int quotationDocEntry, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/sales/from-quotation'),
        headers: ApiService.getHeaders(token: token),
        body: jsonEncode({'quotationDocEntry': quotationDocEntry}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      } else {
        throw Exception('Failed to create sale from quotation');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}