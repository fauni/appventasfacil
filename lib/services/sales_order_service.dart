import 'dart:convert';
import 'package:appventas/models/sales_order/sales_order.dart';
import 'package:appventas/models/sales_order/sales_order_dto.dart';
import 'package:appventas/models/sales_order/sales_order_search_request.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';

class SalesOrderService {
  /// Buscar órdenes de venta con filtros y paginación
  static Future<SalesOrderSearchResponse> searchSalesOrders(
    SalesOrderSearchRequest request,
  ) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      // Construir URL con parámetros de consulta
      final params = request.toQueryParameters();
      final uri = Uri.parse('${ApiService.baseUrl}/SalesOrder/search')
          .replace(queryParameters: params);

      final response = await HttpClient.get(
        uri.toString(),
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];
        return SalesOrderSearchResponse.fromJson(data);
      } else {
        throw Exception('Error al buscar órdenes de venta: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener una orden de venta específica por DocEntry
  static Future<SalesOrder> getSalesOrderById(int docEntry) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/SalesOrder/$docEntry',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final data = jsonResponse['data'];
        return SalesOrder.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Orden de venta no encontrada');
      } else {
        throw Exception('Error al obtener orden de venta: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener órdenes de venta por cliente
  static Future<List<SalesOrder>> getSalesOrdersByCustomer(
    String cardCode, {
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final params = {
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
      };

      final uri = Uri.parse('${ApiService.baseUrl}/SalesOrder/customer/$cardCode')
          .replace(queryParameters: params);

      final response = await HttpClient.get(
        uri.toString(),
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => SalesOrder.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener órdenes del cliente: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener órdenes de venta por vendedor
  static Future<List<SalesOrder>> getSalesOrdersBySalesPerson(
    int slpCode, {
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final params = {
        'pageSize': pageSize.toString(),
        'pageNumber': pageNumber.toString(),
      };

      final uri = Uri.parse('${ApiService.baseUrl}/SalesOrder/salesperson/$slpCode')
          .replace(queryParameters: params);

      final response = await HttpClient.get(
        uri.toString(),
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => SalesOrder.fromJson(json)).toList();
      } else {
        throw Exception('Error al obtener órdenes del vendedor: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Crear una nueva orden de venta
  static Future<String> createSalesOrder(SalesOrderDto orderDto) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.post(
        '${ApiService.baseUrl}/SalesOrder',
        body: orderDto.toJson(),
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      } else {
        final errorResponse = jsonDecode(response.body);
        throw Exception(errorResponse['message'] ?? 'Error al crear orden de venta');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener órdenes recientes (últimas 10)
  static Future<List<SalesOrder>> getRecentSalesOrders() async {
    final request = SalesOrderSearchRequest(
      searchTerm: '',
      pageSize: 10,
      pageNumber: 1,
    );
    
    final response = await searchSalesOrders(request);
    return response.orders;
  }

  /// Obtener órdenes abiertas
  static Future<SalesOrderSearchResponse> getOpenSalesOrders({
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    final request = SalesOrderSearchRequest(
      docStatus: 'O', // O = Open
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    
    return await searchSalesOrders(request);
  }

  /// Obtener órdenes cerradas
  static Future<SalesOrderSearchResponse> getClosedSalesOrders({
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    final request = SalesOrderSearchRequest(
      docStatus: 'C', // C = Closed
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    
    return await searchSalesOrders(request);
  }

  /// Buscar órdenes por rango de fechas
  static Future<SalesOrderSearchResponse> getSalesOrdersByDateRange(
    DateTime dateFrom,
    DateTime dateTo, {
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    final request = SalesOrderSearchRequest(
      dateFrom: dateFrom,
      dateTo: dateTo,
      pageSize: pageSize,
      pageNumber: pageNumber,
    );
    
    return await searchSalesOrders(request);
  }
}