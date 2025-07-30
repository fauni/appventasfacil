// lib/screens/quotation_detail_screen.dart
import 'package:appventas/blocs/quotations/quotations_bloc.dart';
import 'package:appventas/blocs/quotations/quotations_event.dart';
import 'package:appventas/models/sales_quotation.dart';
import 'package:appventas/models/sales_quotation_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class QuotationDetailScreen extends StatelessWidget {
  final SalesQuotation quotation;

  const QuotationDetailScreen({
    Key? key,
    required this.quotation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text('Cotización #${quotation.docNum ?? 'N/A'}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (quotation.docEntry != null)
            IconButton(
              onPressed: () => _convertToSale(context, quotation.docEntry!),
              icon: const Icon(Icons.shopping_cart),
              tooltip: 'Convertir a Venta',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cotización #${quotation.docNum ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Documento: ${quotation.docEntry ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            formatter.format(quotation.docTotal),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Customer Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Cliente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Código:', quotation.cardCode),
                    _buildInfoRow('Nombre:', quotation.cardName),
                    if (quotation.uLbRazonSocial != null)
                      _buildInfoRow('Razón Social:', quotation.uLbRazonSocial!),
                    if (quotation.uNit != null)
                      _buildInfoRow('NIT:', quotation.uNit!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Document Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Documento',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Fecha Documento:',
                      dateFormatter.format(quotation.docDate),
                    ),
                    _buildInfoRow(
                      'Fecha Impuesto:',
                      dateFormatter.format(quotation.taxDate),
                    ),
                    if (quotation.uVfTiempoEntrega != null)
                      _buildInfoRow('Tiempo Entrega:', quotation.uVfTiempoEntrega!),
                    if (quotation.uVfValidezOferta != null)
                      _buildInfoRow('Validez Oferta:', quotation.uVfValidezOferta!),
                    if (quotation.uVfFormaPago != null)
                      _buildInfoRow('Forma de Pago:', quotation.uVfFormaPago!),
                    if (quotation.comments != null && quotation.comments!.isNotEmpty)
                      _buildInfoRow('Comentarios:', quotation.comments!),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Line Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Líneas de la Cotización',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (quotation.lines.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'No hay líneas en esta cotización',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: quotation.lines.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final line = quotation.lines[index];
                          return _buildLineItem(line, formatter);
                        },
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Convert to Sale Button
            if (quotation.docEntry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _convertToSale(context, quotation.docEntry!),
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Convertir a Orden de Venta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineItem(SalesQuotationLine line, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  line.itemCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formatter.format(line.gTotal),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            line.description,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Cantidad: ${line.quantity}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              Text(
                'UOM: ${line.uomCode}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 16),
              Text(
                'Precio: ${formatter.format(line.priceAfVat)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _convertToSale(BuildContext context, int docEntry) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Convertir a Venta'),
          content: const Text(
            '¿Está seguro que desea convertir esta cotización en una orden de venta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<QuotationsBloc>().add(
                      QuotationConvertToSaleRequested(docEntry),
                    );
                Navigator.of(context).pop(); // Return to quotations list
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Convertir'),
            ),
          ],
        );
      },
    );
  }
}