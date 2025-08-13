// lib/widgets/warehouse_stock_modal_separated.dart
import 'package:appventas/blocs/item/item_bloc.dart';
import 'package:appventas/blocs/item/item_event.dart';
import 'package:appventas/blocs/item/item_state.dart';
import 'package:appventas/models/item/item_warehouse_stock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WarehouseStockModal {
  static void show(
    BuildContext context, {
    required String itemCode,
    required String itemName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        // Crear un nuevo ItemBloc independiente para el modal
        create: (context) => ItemBloc(),
        child: _WarehouseStockBottomSheet(
          itemCode: itemCode,
          itemName: itemName,
        ),
      ),
    );
  }
}

class _WarehouseStockBottomSheet extends StatefulWidget {
  final String itemCode;
  final String itemName;

  const _WarehouseStockBottomSheet({
    required this.itemCode,
    required this.itemName,
  });

  @override
  State<_WarehouseStockBottomSheet> createState() => _WarehouseStockBottomSheetState();
}

class _WarehouseStockBottomSheetState extends State<_WarehouseStockBottomSheet> {
  @override
  void initState() {
    super.initState();
    // Cargar stock por almacenes usando el bloc independiente
    context.read<ItemBloc>().add(ItemWarehouseStockRequested(widget.itemCode));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.warehouse,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock por Almacenes',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.itemName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              const Divider(),
              
              // Content
              Expanded(
                child: BlocBuilder<ItemBloc, ItemState>(
                  builder: (context, state) {
                    if (state is ItemWarehouseStockLoading) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Cargando stock por almacenes...'),
                          ],
                        ),
                      );
                    }

                    if (state is ItemError) {
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
                              'Error al cargar stock',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<ItemBloc>().add(
                                  ItemWarehouseStockRequested(widget.itemCode),
                                );
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is ItemWarehouseStockLoaded) {
                      return _buildContent(state.stockResponse, scrollController);
                    }

                    return const Center(
                      child: Text('No hay datos disponibles'),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(ItemWarehouseStockResponse stockResponse, ScrollController scrollController) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      children: [
        // Totales generales
        _buildTotalsCard(stockResponse),
        
        const SizedBox(height: 20),
        
        // Título de almacenes
        Text(
          'Stock por Almacén',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Lista de almacenes
        if (stockResponse.warehouseStocks.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No hay stock en ningún almacén',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          )
        else
          ...stockResponse.warehouseStocks.map(
            (warehouseStock) => _buildWarehouseStockCard(warehouseStock),
          ),
      ],
    );
  }

  Widget _buildTotalsCard(ItemWarehouseStockResponse stockResponse) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: Colors.green[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Totales Generales',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTotalColumn(
                  'En Stock',
                  stockResponse.totalOnHandDisplay,
                  Colors.blue,
                  Icons.inventory,
                ),
              ),
              Expanded(
                child: _buildTotalColumn(
                  'Comprometido',
                  stockResponse.totalIsCommitedDisplay,
                  Colors.orange,
                  Icons.lock,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTotalColumn(
                  'Solicitado',
                  stockResponse.totalOnOrderDisplay,
                  Colors.purple,
                  Icons.shopping_cart,
                ),
              ),
              Expanded(
                child: _buildTotalColumn(
                  'Disponible',
                  stockResponse.totalAvailableDisplay,
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalColumn(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseStockCard(ItemWarehouseStock warehouseStock) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del almacén
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getAvailabilityColor(warehouseStock.available).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.warehouse,
                  color: _getAvailabilityColor(warehouseStock.available),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      warehouseStock.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Disponible: ${warehouseStock.availableDisplay}',
                      style: TextStyle(
                        color: _getAvailabilityColor(warehouseStock.available),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAvailabilityColor(warehouseStock.available).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getAvailabilityColor(warehouseStock.available).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  warehouseStock.onHandDisplay,
                  style: TextStyle(
                    color: _getAvailabilityColor(warehouseStock.available),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Detalles del stock
          Row(
            children: [
              Expanded(
                child: _buildStockDetail(
                  'En Stock',
                  warehouseStock.onHandDisplay,
                  Colors.blue,
                  Icons.inventory,
                ),
              ),
              Expanded(
                child: _buildStockDetail(
                  'Comprometido',
                  warehouseStock.isCommitedDisplay,
                  Colors.orange,
                  Icons.lock,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStockDetail(
                  'Solicitado',
                  warehouseStock.onOrderDisplay,
                  Colors.purple,
                  Icons.shopping_cart,
                ),
              ),
              Expanded(
                child: _buildStockDetail(
                  'Disponible',
                  warehouseStock.availableDisplay,
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockDetail(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 14,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getAvailabilityColor(double available) {
    if (available <= 0) return Colors.red;
    if (available < 10) return Colors.orange;
    return Colors.green;
  }
}