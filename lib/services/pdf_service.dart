import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:appventas/models/quotation/sales_quotation.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static final _currencyFormatter = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ');
  static final _dateFormatter = DateFormat('dd/MM/yyyy');

  static Future<Uint8List> generateQuotationPdf(SalesQuotation quotation) async {
    final pdf = pw.Document();

    // Cargar fuente
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(quotation, fontBold),
          pw.SizedBox(height: 20),
          
          // Customer Information
          _buildCustomerInfo(quotation, font, fontBold),
          pw.SizedBox(height: 20),
          
          // Document Information
          _buildDocumentInfo(quotation, font, fontBold),
          pw.SizedBox(height: 20),
          
          // Terms and Conditions
          if (_hasTerms(quotation)) ...[
            _buildTermsAndConditions(quotation, font, fontBold),
            pw.SizedBox(height: 20),
          ],
          
          // Line Items
          _buildLineItems(quotation, font, fontBold),
          pw.SizedBox(height: 20),
          
          // Total
          _buildTotal(quotation, fontBold),
          
          pw.Spacer(),
          
          // Footer
          _buildFooter(font),
        ],
      ),
    );

    return pdf.save();
  }

  /// Comparte el PDF
  // Comparte el PDF
  static Future<void> shareQuotationPdf(SalesQuotation quotation) async {
    try {
      final pdfBytes = await generateQuotationPdf(quotation);
      
      // Obtener directorio temporal
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/cotizacion_${quotation.docNum ?? 'N-A'}.pdf');
      
      // Escribir el archivo
      await file.writeAsBytes(pdfBytes);
      
      // Compartir
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Cotización #${quotation.docNum ?? 'N/A'}',
        subject: 'Cotización ${quotation.cardName}',
      );
    } catch (e) {
      throw Exception('Error al generar PDF: $e');
    }
  }

  /// Imprime el PDF
  static Future<void> printQuotationPdf(SalesQuotation quotation) async {
    try {
      final pdfBytes = await generateQuotationPdf(quotation);
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Cotización #${quotation.docNum ?? 'N/A'}',
      );
    } catch (e) {
      throw Exception('Error al imprimir PDF: $e');
    }
  }

  /// Vista previa del PDF
  static Future<void> previewQuotationPdf(SalesQuotation quotation) async {
    try {
      final pdfBytes = await generateQuotationPdf(quotation);
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: 'Cotización #${quotation.docNum ?? 'N/A'}',
      );
    } catch (e) {
      throw Exception('Error al mostrar vista previa: $e');
    }
  }

  // Métodos privados para construir secciones del PDF

  static pw.Widget _buildHeader(SalesQuotation quotation, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'COTIZACIÓN',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 24,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Número: ${quotation.docNum ?? 'N/A'}',
                    style: pw.TextStyle(
                      font: fontBold,
                      fontSize: 16,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    'Doc Entry: ${quotation.docEntry ?? 'N/A'}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
              pw.Text(
                _currencyFormatter.format(quotation.docTotal),
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 20,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(SalesQuotation quotation, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL CLIENTE',
            style: pw.TextStyle(font: fontBold, fontSize: 14),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow('Código:', quotation.cardCode, font, fontBold),
          _buildInfoRow('Nombre:', quotation.cardName, font, fontBold),
          if (quotation.uLbRazonSocial != null && quotation.uLbRazonSocial!.isNotEmpty)
            _buildInfoRow('Razón Social:', quotation.uLbRazonSocial!, font, fontBold),
          if (quotation.uNit != null && quotation.uNit!.isNotEmpty)
            _buildInfoRow('NIT:', quotation.uNit!, font, fontBold),
          if (quotation.slpName != null && quotation.slpName!.isNotEmpty)
            _buildInfoRow('Vendedor:', '${quotation.slpName} (${quotation.slpCode})', font, fontBold),
        ],
      ),
    );
  }

  static pw.Widget _buildDocumentInfo(SalesQuotation quotation, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL DOCUMENTO',
            style: pw.TextStyle(font: fontBold, fontSize: 14),
          ),
          pw.SizedBox(height: 12),
          _buildInfoRow('Fecha Documento:', _dateFormatter.format(quotation.docDate), font, fontBold),
          _buildInfoRow('Fecha Impuesto:', _dateFormatter.format(quotation.taxDate), font, fontBold),
          if (quotation.comments != null && quotation.comments!.isNotEmpty)
            _buildInfoRow('Comentarios:', quotation.comments!, font, fontBold),
        ],
      ),
    );
  }

  static pw.Widget _buildTermsAndConditions(SalesQuotation quotation, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TÉRMINOS Y CONDICIONES',
            style: pw.TextStyle(font: fontBold, fontSize: 14),
          ),
          pw.SizedBox(height: 12),
          if (quotation.uVfTiempoEntrega != null && quotation.uVfTiempoEntrega!.isNotEmpty)
            _buildInfoRow(
              'Tiempo de Entrega:', 
              _getDisplayValue(quotation.uVfTiempoEntregaName, quotation.uVfTiempoEntrega), 
              font, 
              fontBold
            ),
          if (quotation.uVfValidezOferta != null && quotation.uVfValidezOferta!.isNotEmpty)
            _buildInfoRow(
              'Validez de Oferta:', 
              _getDisplayValue(quotation.uVfValidezOfertaName, quotation.uVfValidezOferta), 
              font, 
              fontBold
            ),
          if (quotation.uVfFormaPago != null && quotation.uVfFormaPago!.isNotEmpty)
            _buildInfoRow(
              'Forma de Pago:', 
              _getDisplayValue(quotation.uVfFormaPagoName, quotation.uVfFormaPago), 
              font, 
              fontBold
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildLineItems(SalesQuotation quotation, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRODUCTOS',
          style: pw.TextStyle(font: fontBold, fontSize: 14),
        ),
        pw.SizedBox(height: 12),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300),
          columnWidths: {
            0: const pw.FixedColumnWidth(30),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FixedColumnWidth(60),
            3: const pw.FixedColumnWidth(50),
            4: const pw.FixedColumnWidth(80),
            5: const pw.FixedColumnWidth(80),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildTableCell('#', fontBold, isHeader: true),
                _buildTableCell('Producto', fontBold, isHeader: true),
                _buildTableCell('Cantidad', fontBold, isHeader: true),
                _buildTableCell('UOM', fontBold, isHeader: true),
                _buildTableCell('Precio', fontBold, isHeader: true),
                _buildTableCell('Total', fontBold, isHeader: true),
              ],
            ),
            // Data rows
            ...quotation.lines.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final line = entry.value;
              return pw.TableRow(
                children: [
                  _buildTableCell(index.toString(), font),
                  _buildTableCell('${line.itemCode}\n${line.description}', font),
                  _buildTableCell(line.quantity.toString(), font),
                  _buildTableCell(line.uomCode, font),
                  _buildTableCell(_currencyFormatter.format(line.priceAfVat), font),
                  _buildTableCell(_currencyFormatter.format(line.gTotal), font),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTotal(SalesQuotation quotation, pw.Font fontBold) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TOTAL GENERAL:',
            style: pw.TextStyle(font: fontBold, fontSize: 16),
          ),
          pw.Text(
            _currencyFormatter.format(quotation.docTotal),
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 18,
              color: PdfColors.blue900,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Generado desde SAP Sales App',
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
          ),
          pw.Text(
            'Fecha de generación: ${_dateFormatter.format(DateTime.now())}',
            style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  // Helper methods
  static pw.Widget _buildInfoRow(String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: fontBold, fontSize: 10),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static bool _hasTerms(SalesQuotation quotation) {
    return (quotation.uVfTiempoEntrega != null && quotation.uVfTiempoEntrega!.isNotEmpty) ||
           (quotation.uVfValidezOferta != null && quotation.uVfValidezOferta!.isNotEmpty) ||
           (quotation.uVfFormaPago != null && quotation.uVfFormaPago!.isNotEmpty);
  }

  static String _getDisplayValue(String? name, String? code) {
    if (name != null && name.isNotEmpty) {
      return '$name (Código: $code)';
    }
    return 'Código: $code';
  }
}