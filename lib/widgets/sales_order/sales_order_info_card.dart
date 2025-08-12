import 'package:appventas/models/sales_order/sales_order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesOrderInfoCard extends StatelessWidget {
  final SalesOrder order;

  const SalesOrderInfoCard({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Información General',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildStatusChip(context),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow('Número de Orden:', order.docNum.toString()),
            _buildInfoRow('Fecha de Orden:', dateFormat.format(order.docDate)),
            _buildInfoRow('Fecha Contable:', dateFormat.format(order.taxDate)),
            _buildInfoRow('Código Cliente:', order.cardCode),
            _buildInfoRow('Cliente:', order.cardName),
            _buildInfoRow('Vendedor:', '${order.slpCode} - ${order.slpName}'),
            _buildInfoRow('Forma de Pago:', order.pymntGroup),
            _buildInfoRow('Moneda:', order.docCur),
            
            if (order.uLbNit.isNotEmpty)
              _buildInfoRow('NIT/CI:', order.uLbNit),
            
            if (order.uLbRazonSocial.isNotEmpty)
              _buildInfoRow('Razón Social:', order.uLbRazonSocial),
            
            if (order.comments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Comentarios:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.comments,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    
    switch (order.docStatus) {
      case 'O':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'C':
        backgroundColor = Colors.grey.shade100;
        textColor = Colors.grey.shade800;
        break;
      default:
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        order.docStatusDisplay,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}