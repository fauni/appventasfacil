// lib/screens/quotations_screen.dart
import 'package:appventas/screens/quotations/create_quotation_screen.dart';
import 'package:appventas/screens/quotations/quotation_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/quotations/quotations_bloc.dart';
import '../../blocs/quotations/quotations_event.dart';
import '../../blocs/quotations/quotations_state.dart';
import '../../models/sales_quotation.dart';

class QuotationsScreen extends StatefulWidget {
  const QuotationsScreen({Key? key}) : super(key: key);

  @override
  State<QuotationsScreen> createState() => _QuotationsScreenState();
}

class _QuotationsScreenState extends State<QuotationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuotationsBloc>().add(QuotationsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[600],
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cotizaciones',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Gestiona tus cotizaciones de SAP',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateQuotationScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[600],
                  mini: true,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: BlocConsumer<QuotationsBloc, QuotationsState>(
              listener: (context, state) {
                if (state is QuotationsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is QuotationConvertedToSale) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cotización convertida a venta exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Reload quotations
                  context.read<QuotationsBloc>().add(QuotationsLoadRequested());
                }
              },
              builder: (context, state) {
                if (state is QuotationsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is QuotationsLoaded) {
                  if (state.quotations.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<QuotationsBloc>().add(QuotationsLoadRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.quotations.length,
                      itemBuilder: (context, index) {
                        final quotation = state.quotations[index];
                        return _buildQuotationCard(quotation);
                      },
                    ),
                  );
                }

                if (state is QuotationsError) {
                  return _buildErrorState(state.message);
                }

                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationCard(SalesQuotation quotation) {
    final formatter = NumberFormat.currency(locale: 'es_BO', symbol: 'Bs. ');
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuotationDetailScreen(quotation: quotation),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cotización #${quotation.docNum ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quotation.cardName,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatter.format(quotation.docTotal),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[600],
                        ),
                      ),
                      Text(
                        dateFormatter.format(quotation.docDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (quotation.comments != null && quotation.comments!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  quotation.comments!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuotationDetailScreen(
                              quotation: quotation,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Ver Detalle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[600],
                        side: BorderSide(color: Colors.blue[600]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: quotation.docEntry != null
                          ? () => _convertToSale(quotation.docEntry!)
                          : null,
                      icon: const Icon(Icons.shopping_cart, size: 16),
                      label: const Text('Crear Venta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay cotizaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primera cotización',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateQuotationScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Nueva Cotización'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar cotizaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<QuotationsBloc>().add(QuotationsLoadRequested());
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _convertToSale(int docEntry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Convertir a Venta'),
          content: const Text(
            '¿Está seguro que desea convertir esta cotización en una orden de venta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<QuotationsBloc>().add(
                      QuotationConvertToSaleRequested(docEntry),
                    );
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