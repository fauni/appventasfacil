// lib/screens/sale_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaleDetailScreen extends StatelessWidget {
  final dynamic sale;

  const SaleDetailScreen({
    Key? key,
    required this.sale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    final docNum = sale['docNum']?.toString() ?? 'N/A';
    final docEntry = sale['docEntry']?.toString() ?? 'N/A';
    final cardName = sale['cardName']?.toString() ?? 'Cliente no disponible';
    final cardCode = sale['cardCode']?.toString() ?? 'N/A';
    final docTotal = (sale['docTotal'] as num?)?.toDouble() ?? 0.0;
    final docDate = sale['docDate'] != null 
        ? DateTime.tryParse(sale['docDate'].toString()) ?? DateTime.now()
        : DateTime.now();
    final taxDate = sale['taxDate'] != null 
        ? DateTime.tryParse(sale['taxDate'].toString()) ?? DateTime.now()
        : DateTime.now();
    final status = sale['status']?.toString() ?? 'Abierto';
    final comments = sale['comments']?.toString() ?? '';
    final slpCode = sale['slpCode']?.toString() ?? '';
    final uNit = sale['u_NIT']?.toString() ?? '';
    final uLbRazonSocial = sale['u_LB_RazonSocial']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Venta #$docNum'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.print, size: 18),
                    SizedBox(width: 8),
                    Text('Imprimir'),
                  ],
                ),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función de impresión próximamente disponible'),
                      ),
                    );
                  });
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.email, size: 18),
                    SizedBox(width: 8),
                    Text('Enviar Email'),
                  ],
                ),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función de email próximamente disponible'),
                      ),
                    );
                  });
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 100), () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Función de edición próximamente disponible'),
                      ),
                    );
                  });
                },
              ),
            ],
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
                              'Orden de Venta #$docNum',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Documento: $docEntry',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Estado: ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[700],
                                ),
                              ),
                              Text(
                                formatter.format(docTotal),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
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
                    _buildInfoRow('Código:', cardCode),
                    _buildInfoRow('Nombre:', cardName),
                    if (uLbRazonSocial.isNotEmpty)
                      _buildInfoRow('Razón Social:', uLbRazonSocial),
                    if (uNit.isNotEmpty)
                      _buildInfoRow('NIT:', uNit),
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
                      dateFormatter.format(docDate),
                    ),
                    _buildInfoRow(
                      'Fecha Impuesto:',
                      dateFormatter.format(taxDate),
                    ),
                    _buildInfoRow('Total:', formatter.format(docTotal)),
                    if (slpCode.isNotEmpty)
                      _buildInfoRow('Vendedor:', slpCode),
                    if (comments.isNotEmpty)
                      _buildInfoRow('Comentarios:', comments),
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
                      'Líneas de la Venta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Check if lines exist in sale data
                    if (sale['lines'] != null && sale['lines'].isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sale['lines'].length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final line = sale['lines'][index];
                          return _buildLineItem(line, formatter);
                        },
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 32,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Detalles de líneas no disponibles',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Los detalles de las líneas se mostrarán cuando estén disponibles desde la API',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de impresión próximamente disponible'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimir'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange[600],
                      side: BorderSide(color: Colors.orange[600]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de email próximamente disponible'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.email),
                    label: const Text('Enviar por Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'abierto':
      case 'open':
        return Colors.green;
      case 'cerrado':
      case 'closed':
        return Colors.red;
      case 'cancelado':
      case 'cancelled':
        return Colors.orange;
      case 'pendiente':
      case 'pending':
        return Colors.yellow[700]!;
      default:
        return Colors.blue;
    }
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

  Widget _buildLineItem(dynamic line, NumberFormat formatter) {
    final itemCode = line['itemCode']?.toString() ?? 'N/A';
    final description = line['dscription']?.toString() ?? line['description']?.toString() ?? 'Sin descripción';
    final quantity = (line['quantity'] as num?)?.toDouble() ?? 0.0;
    final uomCode = line['uomCode']?.toString() ?? 'UN';
    final priceAfVat = (line['priceAfVAT'] as num?)?.toDouble() ?? (line['priceAfVat'] as num?)?.toDouble() ?? 0.0;
    final lineTotal = (line['lineTotal'] as num?)?.toDouble() ?? 0.0;
    final gTotal = (line['gTotal'] as num?)?.toDouble() ?? lineTotal;

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
                  itemCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formatter.format(gTotal),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Cantidad: $quantity',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'UOM: $uomCode',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'Precio: ${formatter.format(priceAfVat)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal: ${formatter.format(lineTotal)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Total: ${formatter.format(gTotal)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}