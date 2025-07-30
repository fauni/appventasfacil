import 'dart:convert';

import 'package:appventas/models/customer.dart';
import 'package:appventas/services/api_service.dart';
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
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/Customer/search').replace(
        queryParameters: {
          'searchTerm': searchTerm,
          'pageSize': pageSize.toString(),
          'pageNumber': pageNumber.toString(),
        },
      );

      final response = await http.get(uri, headers: ApiService.getHeaders(token: token));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return CustomerSearchResponse.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to search customers');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Obtener cliente por código
  static Future<Customer> getCustomerByCode(String cardCode) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/Customer/$cardCode'),
        headers: ApiService.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return Customer.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Customer not found');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Obtener todos los clientes
  static Future<List<Customer>> getAllCustomers() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/Customer'),
        headers: ApiService.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Autocompletado de clientes
  static Future<List<CustomerAutocomplete>> getCustomersAutocomplete(String term) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/Customer/autocomplete').replace(
        queryParameters: {'term': term},
      );

      final response = await http.get(uri, headers: ApiService.getHeaders(token: token));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => CustomerAutocomplete.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get autocomplete data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}