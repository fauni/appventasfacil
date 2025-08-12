import 'package:appventas/models/sales_order/sales_order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesOrderLinesCard extends StatelessWidget {
  final SalesOrder order;

  const SalesOrderLinesCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(symbol: 'Bs. ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Líneas de la Orden',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 16),
            
            ...order.lines.map((line) => _buildLineItem(context, line, numberFormat)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(BuildContext context, SalesOrderLine line, NumberFormat numberFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con código y nombre
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.itemCode,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      line.displayName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                line.lineStatusDisplay,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: line.lineStatus == 'O' 
                      ? Colors.green.shade700 
                      : Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Detalles de cantidad y precio
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Cantidad:', 
                  '${line.quantity.toStringAsFixed(2)} ${line.uomCode}',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Precio:', 
                  numberFormat.format(line.priceAfVAT),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 4),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Almacén:', 
                  '${line.whsCode} - ${line.whsName}',
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Total:', 
                  numberFormat.format(line.gTotal),
                ),
              ),
            ],
          ),
          
          if (line.discPrcnt > 0) ...[
            const SizedBox(height: 4),
            _buildDetailItem(
              'Descuento:', 
              '${line.discPrcnt.toStringAsFixed(2)}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            TextSpan(text: ' $value'),
          ],
        ),
      ),
    );
  }
}