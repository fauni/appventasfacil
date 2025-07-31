import 'dart:convert';

import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';
import 'package:http/http.dart' as http;


class CustomerService {
  static Future<CustomerSearchResponse> searchCustomers({
    String searchTerm = '',
    int pageSize = 20,
    int pageNumber = 1
  }) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/Customer/search').replace(
        queryParameters: {
          'searchTerm': searchTerm,
          'pageSize': pageSize.toString(),
          'pageNumber': pageNumber.toString(),
        },
      );

      final response = await HttpClient.get(uri.toString(), token: token);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CustomerSearchResponse.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to search customers');
      }
    } on UnauthorizedException{
      // Re-lanzar para que el Bloc lo maneje
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Obtener cliente por código
  static Future<Customer> getCustomerByCode(String cardCode) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get('${ApiService.baseUrl}/Customer/$cardCode', token: token);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Customer.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 404){
        throw Exception('Cliente no encontrado');
      }else {
        throw Exception('Error al obtener cliente: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Obtener todos los clientes
  static Future<List<Customer>> getAllCustomers() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get('${ApiService.baseUrl}/Customer', token: token);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar clientes: ${response.statusCode}');
      }
    } on UnauthorizedException{
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  // Autocompletado de clientes
  static Future<List<CustomerAutocomplete>> getCustomersAutocomplete(String term) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/Customer/autocomplete').replace(
        queryParameters: {'term': term},
      );

      final response = await HttpClient.get(uri.toString(), token: token);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => CustomerAutocomplete.fromJson(json)).toList();
      } else {
        throw Exception('Error en autocompletado: ${response.statusCode}');
      }
    } on UnauthorizedException{
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}