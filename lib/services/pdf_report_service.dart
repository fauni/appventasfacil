// lib/services/pdf_report_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:appventas/services/api_service.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';

class PdfReportService {
  /// Descarga PDF directamente como bytes desde la API
  static Future<Uint8List> downloadQuotationPdf(int docEntry) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/Reports/quotation/$docEntry/pdf',
        token: token,
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Error al descargar PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Descarga PDF como Base64 desde la API
  static Future<Uint8List> downloadQuotationPdfBase64(int docEntry) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/Reports/quotation/$docEntry/pdf/base64',
        token: token,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final base64String = jsonResponse['data'];
        return base64Decode(base64String);
      } else {
        throw Exception('Error al descargar PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }

  /// Comparte el PDF descargado de la API
  static Future<void> shareQuotationPdf(int docEntry, String docNum) async {
    try {
      final pdfBytes = await downloadQuotationPdf(docEntry);
      
      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/cotizacion_$docNum.pdf');
      
      // Escribir el archivo
      await file.writeAsBytes(pdfBytes);
      
      // Compartir
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Cotización #$docNum',
        subject: 'Cotización generada desde SAP Sales App',
      );
    } catch (e) {
      throw Exception('Error al compartir PDF: $e');
    }
  }

  /// Imprime el PDF descargado de la API
  static Future<void> printQuotationPdf(int docEntry, String docNum) async {
    try {
      final pdfBytes = await downloadQuotationPdf(docEntry);
      
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Cotización #$docNum',
      );
    } catch (e) {
      throw Exception('Error al imprimir PDF: $e');
    }
  }

  /// Vista previa del PDF descargado de la API
  static Future<void> previewQuotationPdf(int docEntry, String docNum) async {
    try {
      final pdfBytes = await downloadQuotationPdf(docEntry);
      
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Cotización #$docNum',
      );
    } catch (e) {
      throw Exception('Error al mostrar vista previa: $e');
    }
  }

  /// Guarda el PDF en el dispositivo (para uso avanzado)
  static Future<String> saveQuotationPdf(int docEntry, String docNum) async {
    try {
      final pdfBytes = await downloadQuotationPdf(docEntry);
      
      // Obtener directorio de documentos
      final documentsDir = await getApplicationDocumentsDirectory();
      final file = File('${documentsDir.path}/cotizacion_$docNum.pdf');
      
      // Escribir el archivo
      await file.writeAsBytes(pdfBytes);
      
      return file.path;
    } catch (e) {
      throw Exception('Error al guardar PDF: $e');
    }
  }

  /// Verifica si el PDF está disponible
  static Future<bool> isPdfAvailable(int docEntry) async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return false;

      final response = await HttpClient.get(
        '${ApiService.baseUrl}/Reports/quotation/$docEntry/pdf',
        token: token,
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}