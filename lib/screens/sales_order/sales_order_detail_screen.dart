import 'package:appventas/models/sales_order/sales_order_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:appventas/blocs/sales_order/sales_order_bloc.dart';
import 'package:appventas/blocs/sales_order/sales_order_event.dart';
import 'package:appventas/blocs/sales_order/sales_order_state.dart';
import 'package:appventas/models/sales_order/sales_order.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final SalesOrder order;

  const SalesOrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen> {
  late SalesOrder _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _loadOrderDetails();
  }

  void _loadOrderDetails() {
    context.read<SalesOrderBloc>().add(SalesOrderByIdRequested(_currentOrder.docEntry));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden #${_currentOrder.docNum}'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadOrderDetails,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'share':
                  _shareOrder();
                  break;
                case 'print':
                  _printOrder();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Compartir'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'print',
                child: Row(
                  children: [
                    Icon(Icons.print),
                    SizedBox(width: 8),
                    Text('Imprimir'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocListener<SalesOrderBloc, SalesOrderState>(
        listener: (context, state) {
          if (state is SalesOrderDetailLoaded) {
            setState(() {
              _currentOrder = state.salesOrder;
            });
          }
          if (state is SalesOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<SalesOrderBloc, SalesOrderState>(
          builder: (context, state) {
            if (state is SalesOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return _buildOrderDetail();
          },
        ),
      ),
    );
  }

  Widget _buildOrderDetail() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderHeader(),
          const SizedBox(height: 16),
          _buildCustomerInfo(),
          const SizedBox(height: 16),
          _buildOrderInfo(),
          const SizedBox(height: 16),
          _buildProductsSection(),
          const SizedBox(height: 16),
          _buildTotalSection(),
          if (_currentOrder.comments.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildCommentsSection(),
          ],
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                      'Orden de Venta',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${_currentOrder.docNum}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.blue[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                _buildStatusChip(_currentOrder.docStatus),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    'DocEntry:',
                    _currentOrder.docEntry.toString(),
                    Icons.tag,
                  ),
                ),
                Expanded(
                  child: _buildInfoRow(
                    'Fecha:',
                    DateFormat('dd/MM/yyyy').format(_currentOrder.docDate),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Vencimiento:',
              DateFormat('dd/MM/yyyy').format(_currentOrder.docDueDate),
              Icons.event,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Información del Cliente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Código:', _currentOrder.cardCode, Icons.account_box),
            _buildInfoRow('Nombre:', _currentOrder.cardName, Icons.business),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Información de la Orden',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentOrder.salesPersonName.isNotEmpty)
              _buildInfoRow('Vendedor:', _currentOrder.salesPersonName, Icons.person_outline),
            _buildInfoRow(
              'Total:',
              'Bs. ${_currentOrder.docTotal.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Productos (${_currentOrder.lines.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentOrder.lines.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'No hay productos en esta orden',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _currentOrder.lines.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final line = _currentOrder.lines[index];
                  return _buildProductCard(line, index + 1);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(SalesOrderLine line, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.itemCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (line.description.isNotEmpty)
                      Text(
                        line.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Cantidad',
                        '${line.quantity.toStringAsFixed(2)} ${line.uomCode}',
                        Icons.inventory_2,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Precio Unit.',
                        'Bs. ${line.price.toStringAsFixed(2)}',
                        Icons.attach_money,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Almacén',
                        line.warehouseCode.isNotEmpty ? line.warehouseCode : 'N/A',
                        Icons.warehouse,
                        Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Total Línea',
                        'Bs. ${line.lineTotal.toStringAsFixed(2)}',
                        Icons.calculate,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calculate, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Resumen Total',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green[50]!, Colors.green[100]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[300]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL GENERAL:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Bs. ${_currentOrder.docTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.green[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Incluye todos los impuestos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.comment, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Comentarios',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                _currentOrder.comments,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareOrder,
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _printOrder,
            icon: const Icon(Icons.print),
            label: const Text('Imprimir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String displayText;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'open':
      case 'o':
        color = Colors.blue;
        displayText = 'Abierta';
        icon = Icons.lock_open;
        break;
      case 'closed':
      case 'c':
        color = Colors.green;
        displayText = 'Cerrada';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
      case 'x':
        color = Colors.red;
        displayText = 'Cancelada';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        displayText = status;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            displayText,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== MÉTODOS DE FUNCIONALIDAD ====================

  void _shareOrder() {
    // Implementar funcionalidad de compartir
    // Puede ser compartir como texto, PDF, o link
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir Orden'),
        content: const Text('¿Cómo desea compartir esta orden de venta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _shareAsText();
            },
            child: const Text('Como Texto'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _shareAsPdf();
            },
            child: const Text('Como PDF'),
          ),
        ],
      ),
    );
  }

  void _shareAsText() {
    final text = '''
Orden de Venta #${_currentOrder.docNum}
DocEntry: ${_currentOrder.docEntry}
Cliente: ${_currentOrder.cardCode} - ${_currentOrder.cardName}
Fecha: ${DateFormat('dd/MM/yyyy').format(_currentOrder.docDate)}
Total: Bs. ${_currentOrder.docTotal.toStringAsFixed(2)}
Estado: ${_getStatusText(_currentOrder.docStatus)}

${_currentOrder.comments.isNotEmpty ? 'Comentarios: ${_currentOrder.comments}' : ''}

Generado desde SAP Sales App
''';

    // Aquí implementarías el share real usando share_plus
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Texto copiado: $text'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareAsPdf() {
    // Aquí implementarías la generación y compartir PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de PDF en desarrollo...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _printOrder() {
    // Implementar funcionalidad de impresión
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de impresión en desarrollo...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'o':
        return 'Abierta';
      case 'closed':
      case 'c':
        return 'Cerrada';
      case 'cancelled':
      case 'x':
        return 'Cancelada';
      default:
        return status;
    }
  }
}