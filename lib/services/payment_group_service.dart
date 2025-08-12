import 'dart:convert';

import 'package:appventas/models/payment_group/payment_group.dart';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';

class PaymentGroupService {
  static Future<PaymentGroupSearchResponse> searchPaymentGroups({
    String searchTerm = '',
    int pageSize = 20,
    int pageNumber = 1
  }) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final uri = Uri.parse('${ApiService.baseUrl}/PaymentGroup/search').replace(
        queryParameters: {
          'searchTerm': searchTerm,
          'pageSize': pageSize.toString(),
          'pageNumber': pageNumber.toString(),
        },
      );

      final response = await HttpClient.get(uri.toString(), token: token);
      if(response.statusCode == 200){
        final jsonResponse = jsonDecode(response.body);
        return PaymentGroupSearchResponse.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Failed to search payment groups');
      }
    } on UnauthorizedException{
      rethrow;
    }catch(e) {
      throw Exception('Network error: $e');
    }
  }

  // Obtener grupo de pago por número de grupo
  static Future<PaymentGroup> getPaymentGroupByGroupNum(int groupNum) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw UnauthorizedException('No hay token de autenticación');
      }

      final response = await HttpClient.get('${ApiService.baseUrl}/PaymentGroup/$groupNum', token: token);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return PaymentGroup.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 404) {
        throw Exception('Grupo de pago no encontrado');
      } else {
        throw Exception('Failed to get payment group');
      }
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}