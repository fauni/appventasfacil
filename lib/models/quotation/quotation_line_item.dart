// Clase helper para manejar las líneas de cotización con items
import 'package:appventas/models/item/item.dart';
import 'package:appventas/models/item/unit_of_measure.dart';

class QuotationLineItem {
  final String id;
  final String itemCode;
  final Item? selectedItem;
  final double quantity;
  final double priceAfterVAT;
  final UnitOfMeasure? selectedUom;

  QuotationLineItem({
    required this.id,
    required this.itemCode,
    this.selectedItem,
    required this.quantity,
    required this.priceAfterVAT,
    this.selectedUom,
  });

  QuotationLineItem copyWith({
    String? id,
    String? itemCode,
    Item? selectedItem,
    double? quantity,
    double? priceAfterVAT,
    UnitOfMeasure? selectedUom,
  }) {
    return QuotationLineItem(
      id: id ?? this.id,
      itemCode: itemCode ?? this.itemCode,
      selectedItem: selectedItem ?? this.selectedItem,
      quantity: quantity ?? this.quantity,
      priceAfterVAT: priceAfterVAT ?? this.priceAfterVAT,
      selectedUom: selectedUom,
    );
  }
}