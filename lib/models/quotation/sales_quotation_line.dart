class SalesQuotationLine {
  final String itemCode;
  final String description;
  final double quantity;
  final String uomCode;
  final double priceAfVat;
  final double lineTotal;
  final double gTotal;

  SalesQuotationLine({
    required this.itemCode,
    required this.description,
    required this.quantity,
    required this.uomCode,
    required this.priceAfVat,
    required this.lineTotal,
    required this.gTotal,
  });

  factory SalesQuotationLine.fromJson(Map<String, dynamic> json) {
    return SalesQuotationLine(
      itemCode: json['itemCode'],
      description: json['dscription'],
      quantity: json['quantity'].toDouble(),
      uomCode: json['uomCode'],
      priceAfVat: json['priceAfVAT'].toDouble(),
      lineTotal: json['lineTotal'].toDouble(),
      gTotal: json['gTotal'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'dscription': description,
      'quantity': quantity,
      'uomCode': uomCode,
      'priceAfVAT': priceAfVat,
      'lineTotal': lineTotal,
      'gTotal': gTotal,
    };
  }
}