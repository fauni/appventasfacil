// lib/models/sales_order/sales_order_line_dto.dart
class SalesOrderLineDto {
  final String itemCode;
  final double quantity;
  final String taxCode;
  final double priceAfterVAT;
  final double discountPercent;
  final int uoMEntry;
  final DateTime shipDate;
  final String warehouseCode;
  final String uDescitemfacil;
  final double uPrecioVenta;
  final double uPrecioItemVenta;
  final String uTfeCodeUMfact;
  final String uTfeNomUMfact;

  SalesOrderLineDto({
    required this.itemCode,
    required this.quantity,
    required this.taxCode,
    required this.priceAfterVAT,
    required this.discountPercent,
    required this.uoMEntry,
    required this.shipDate,
    required this.warehouseCode,
    required this.uDescitemfacil,
    required this.uPrecioVenta,
    required this.uPrecioItemVenta,
    required this.uTfeCodeUMfact,
    required this.uTfeNomUMfact,
  });

  Map<String, dynamic> toJson() {
    return {
      'ItemCode': itemCode,
      'Quantity': quantity,
      'TaxCode': taxCode,
      'PriceAfterVAT': priceAfterVAT,
      'DiscountPercent': discountPercent,
      'UoMEntry': uoMEntry,
      'ShipDate': shipDate.toIso8601String(),
      'WarehouseCode': warehouseCode,
      'U_descitemfacil': uDescitemfacil,
      'U_PrecioVenta': uPrecioVenta,
      'U_PrecioItemVenta': uPrecioItemVenta,
      'U_TFE_codUMfact': uTfeCodeUMfact,
      'U_TFE_nomUMfact': uTfeNomUMfact,
    };
  }

  factory SalesOrderLineDto.fromJson(Map<String, dynamic> json) {
    return SalesOrderLineDto(
      itemCode: json['ItemCode'],
      quantity: (json['Quantity'] as num).toDouble(),
      taxCode: json['TaxCode'],
      priceAfterVAT: (json['PriceAfterVAT'] as num).toDouble(),
      discountPercent: (json['DiscountPercent'] as num).toDouble(),
      uoMEntry: json['UoMEntry'],
      shipDate: DateTime.parse(json['ShipDate']),
      warehouseCode: json['WarehouseCode'],
      uDescitemfacil: json['U_descitemfacil'],
      uPrecioVenta: (json['U_PrecioVenta'] as num).toDouble(),
      uPrecioItemVenta: (json['U_PrecioItemVenta'] as num).toDouble(),
      uTfeCodeUMfact: json['U_TFE_codUMfact'],
      uTfeNomUMfact: json['U_TFE_nomUMfact'],
    );
  }
}