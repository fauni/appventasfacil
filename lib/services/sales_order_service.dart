// lib/services/sales_order_service.dart
import 'dart:convert';
import 'package:appventas/models/sales_order/sales_order_dto.dart';
import 'package:appventas/models/sales_order/sales_order_response.dart';
import 'package:appventas/models/sales_order/sales_order.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';

class SalesOrderService {
  /// Crear una nueva orden de venta
  static Future<SalesOrderResponse> createSalesOrder(SalesOrderDto salesOrderDto) async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.post(
        '${ApiService.baseUrl}/SalesOrder',
        body: salesOrderDto.toJson(),
        token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return SalesOrderResponse.fromJson(jsonResponse['data']);
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

  /// Obtener todas las órdenes de venta
  static Future<List<SalesOrder>> getSalesOrders() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/SalesOrder',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> data = jsonResponse['data'];
        return data.map((json) => SalesOrder.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar órdenes de venta: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Obtener una orden de venta por su DocEntry
  static Future<SalesOrder?> getSalesOrderById(int docEntry) async {
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
        return SalesOrder.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al cargar orden de venta: ${response.statusCode}');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}