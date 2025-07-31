// Clase helper para manejar las líneas de cotización
import 'package:appventas/models/item/unit_of_measure.dart';

class QuotationLineItem {
  final String id;
  final String itemCode;
  final double quantity;
  final double priceAfterVAT;
  final UnitOfMeasure? selectedUom;

  QuotationLineItem({
    required this.id,
    required this.itemCode,
    required this.quantity,
    required this.priceAfterVAT,
    this.selectedUom,
  });

  QuotationLineItem copyWith({
    String? id,
    String? itemCode,
    double? quantity,
    double? priceAfterVAT,
    UnitOfMeasure? selectedUom,
  }) {
    return QuotationLineItem(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      quantity: quantity ?? this.quantity,
      priceAfterVAT: priceAfterVAT ?? this.priceAfterVAT,
      selectedUom: selectedUom,
    );
  }
}