import 'package:appventas/widgets/warehouse_stock_modal.dart';
import 'package:flutter/material.dart';

class WarehouseStockButton extends StatelessWidget {
  final String itemCode;
  final String itemName;
  final double currentStock;

  const WarehouseStockButton({
    Key? key,
    required this.itemCode,
    required this.itemName,
    required this.currentStock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () => _showWarehouseStock(context),
        icon: const Icon(Icons.warehouse, size: 20),
        label: const Text('Ver Stock por Almacenes'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  void _showWarehouseStock(BuildContext context) {
    WarehouseStockModal.show(
      context,
      itemCode: itemCode,
      itemName: itemName,
    );
  }
}

// Widget compacto para mostrar en cards usando Modal con bloc separado
class CompactWarehouseStockButton extends StatelessWidget {
  final String itemCode;
  final String itemName;
  final double currentStock;

  const CompactWarehouseStockButton({
    Key? key,
    required this.itemCode,
    required this.itemName,
    required this.currentStock,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showWarehouseStock(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.indigo[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.indigo[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warehouse,
              size: 16,
              color: Colors.indigo[600],
            ),
            const SizedBox(width: 6),
            Text(
              'Ver por almacén',
              style: TextStyle(
                fontSize: 12,
                color: Colors.indigo[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWarehouseStock(BuildContext context) {
    WarehouseStockModal.show(
      context,
      itemCode: itemCode,
      itemName: itemName,
    );
  }
}