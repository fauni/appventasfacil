import 'package:appventas/blocs/sales_orders/sales_orders_bloc.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_event.dart';
import 'package:appventas/blocs/sales_orders/sales_orders_state.dart';
import 'package:appventas/models/sales_order/sales_order.dart';
import 'package:appventas/widgets/sales_order/sales_order_info_card.dart';
import 'package:appventas/widgets/sales_order/sales_order_lines_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class SalesOrderDetailScreen extends StatefulWidget {
  final int docEntry;

  const SalesOrderDetailScreen({
    Key? key,
    required this.docEntry,
  }) : super(key: key);

  @override
  State<SalesOrderDetailScreen> createState() => _SalesOrderDetailScreenState();
}

class _SalesOrderDetailScreenState extends State<SalesOrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar detalle de la orden
    context.read<SalesOrdersBloc>().add(SalesOrderDetailRequested(widget.docEntry));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orden ${widget.docEntry}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implementar compartir
            },
          ),
        ],
      ),
      body: BlocBuilder<SalesOrdersBloc, SalesOrdersState>(
        builder: (context, state) {
          if (state is SalesOrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is SalesOrdersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar la orden',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SalesOrdersBloc>().add(
                        SalesOrderDetailRequested(widget.docEntry),
                      );
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          if (state is SalesOrderDetailLoaded) {
            final order = state.order;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Información general
                  SalesOrderInfoCard(order: order),
                  
                  const SizedBox(height: 16),
                  
                  // Líneas de la orden
                  SalesOrderLinesCard(order: order),
                  
                  const SizedBox(height: 16),
                  
                  // Resumen de totales
                  _buildTotalsCard(order),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTotalsCard(SalesOrder order) {
    final numberFormat = NumberFormat.currency(symbol: 'Bs. ');
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            _buildTotalRow('Descuento:', '${order.discPrcnt.toStringAsFixed(2)}%'),
            _buildTotalRow('Impuestos:', numberFormat.format(order.vatSum)),
            const Divider(),
            _buildTotalRow(
              'Total:', 
              numberFormat.format(order.docTotal),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}