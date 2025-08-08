// lib/models/sales_order/sales_order_line.dart
class SalesOrderLine {
  final int lineNum;
  final String itemCode;
  final String description;
  final double quantity;
  final double price;
  final double lineTotal;
  final String uomCode;
  final String warehouseCode;

  SalesOrderLine({
    required this.lineNum,
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.price,
    required this.lineTotal,
    required this.uomCode,
    required this.warehouseCode,
  });

  factory SalesOrderLine.fromJson(Map<String, dynamic> json) {
    return SalesOrderLine(
      lineNum: json['LineNum'],
      itemCode: json['ItemCode'],
      description: json['Dscription'] ?? json['Description'] ?? '',
      quantity: (json['Quantity'] as num).toDouble(),
      price: (json['Price'] as num).toDouble(),
      lineTotal: (json['LineTotal'] as num).toDouble(),
      uomCode: json['UomCode'] ?? '',
      warehouseCode: json['WarehouseCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'LineNum': lineNum,
      'ItemCode': itemCode,
      'Dscription': description,
      'Quantity': quantity,
      'Price': price,
      'LineTotal': lineTotal,
      'UomCode': uomCode,
      'WarehouseCode': warehouseCode,
    };
  }
}