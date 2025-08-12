import 'package:equatable/equatable.dart';

class SalesOrderDto extends Equatable {
  final String cardCode;
  final String comments;
  final int salesPersonCode;
  final int? series;
  final int? contactPersonCode;
  final int? paymentGroupCode;
  final String uUsrventafacil;
  final String? uLatitud;
  final String? uLongitud;
  final String? uVfTiempoEntrega;
  final String? uVfValidezOferta;
  final String? uVfFormaPago;
  final DateTime uFecharegistroapp;
  final DateTime uHoraregistroapp;
  
  // Campos adicionales para SAP Service Layer
  final String? cardForeignName;
  final String? uCodigocliente;
  final String? uLbRazonSocial;
  final String? uNit;
  final String? uLbNit;
  final String? defaultWarehouseCode;
  final String? defaultTaxCode;
  
  final List<SalesOrderLineDto> documentLines;

  const SalesOrderDto({
    required this.cardCode,
    required this.comments,
    required this.salesPersonCode,
    this.series,
    this.contactPersonCode,
    this.paymentGroupCode,
    required this.uUsrventafacil,
    this.uLatitud,
    this.uLongitud,
    this.uVfTiempoEntrega,
    this.uVfValidezOferta,
    this.uVfFormaPago,
    required this.uFecharegistroapp,
    required this.uHoraregistroapp,
    this.cardForeignName,
    this.uCodigocliente,
    this.uLbRazonSocial,
    this.uNit,
    this.uLbNit,
    this.defaultWarehouseCode,
    this.defaultTaxCode = 'IVA',
    required this.documentLines,
  });

  Map<String, dynamic> toJson() {
    return {
      'CardCode': cardCode,
      'Comments': comments,
      'SalesPersonCode': salesPersonCode,
      'Series': series,
      'ContactPersonCode': contactPersonCode,
      'PaymentGroupCode': paymentGroupCode,
      'U_usrventafacil': uUsrventafacil,
      'U_latitud': uLatitud,
      'U_longitud': uLongitud,
      'U_VF_TiempoEntrega': uVfTiempoEntrega,
      'U_VF_ValidezOferta': uVfValidezOferta,
      'U_VF_FormaPago': uVfFormaPago,
      'U_fecharegistroapp': uFecharegistroapp.toIso8601String(),
      'U_horaregistroapp': uHoraregistroapp.toIso8601String(),
      'CardForeignName': cardForeignName,
      'U_codigocliente': uCodigocliente,
      'U_LB_RazonSocial': uLbRazonSocial,
      'U_NIT': uNit,
      'U_LB_NIT': uLbNit,
      'DefaultWarehouseCode': defaultWarehouseCode,
      'DefaultTaxCode': defaultTaxCode,
      'DocumentLines': documentLines.map((line) => line.toJson()).toList(),
    };
  }

  factory SalesOrderDto.fromJson(Map<String, dynamic> json) {
    return SalesOrderDto(
      cardCode: json['CardCode'] ?? '',
      comments: json['Comments'] ?? '',
      salesPersonCode: json['SalesPersonCode'] ?? 0,
      series: json['Series'],
      contactPersonCode: json['ContactPersonCode'],
      paymentGroupCode: json['PaymentGroupCode'],
      uUsrventafacil: json['U_usrventafacil'] ?? '',
      uLatitud: json['U_latitud'],
      uLongitud: json['U_longitud'],
      uVfTiempoEntrega: json['U_VF_TiempoEntrega'],
      uVfValidezOferta: json['U_VF_ValidezOferta'],
      uVfFormaPago: json['U_VF_FormaPago'],
      uFecharegistroapp: DateTime.parse(json['U_fecharegistroapp']),
      uHoraregistroapp: DateTime.parse(json['U_horaregistroapp']),
      cardForeignName: json['CardForeignName'],
      uCodigocliente: json['U_codigocliente'],
      uLbRazonSocial: json['U_LB_RazonSocial'],
      uNit: json['U_NIT'],
      uLbNit: json['U_LB_NIT'],
      defaultWarehouseCode: json['DefaultWarehouseCode'],
      defaultTaxCode: json['DefaultTaxCode'] ?? 'IVA',
      documentLines: (json['DocumentLines'] as List<dynamic>?)
          ?.map((line) => SalesOrderLineDto.fromJson(line))
          .toList() ?? [],
    );
  }

  double get totalAmount {
    return documentLines.fold(0.0, (sum, line) => sum + line.lineTotal);
  }

  @override
  List<Object?> get props => [
    cardCode, comments, salesPersonCode, series, contactPersonCode, paymentGroupCode,
    uUsrventafacil, uLatitud, uLongitud, uVfTiempoEntrega, uVfValidezOferta, uVfFormaPago,
    uFecharegistroapp, uHoraregistroapp, cardForeignName, uCodigocliente, uLbRazonSocial,
    uNit, uLbNit, defaultWarehouseCode, defaultTaxCode, documentLines,
  ];
}

class SalesOrderLineDto extends Equatable {
  final String itemCode;
  final double quantity;
  final double priceAfterVAT;
  final int uomEntry;
  
  // Campos adicionales para Service Layer
  final String? taxCode;
  final double discountPercent;
  final DateTime? shipDate;
  final String? warehouseCode;
  final String? uDescitemfacil; // Descripción personalizable del item
  final double? uPrecioVenta;
  final double? uPrecioItemVenta;
  final String? uTfeCodeUMfact;
  final String? uTfeNomUMfact;

  const SalesOrderLineDto({
    required this.itemCode,
    required this.quantity,
    required this.priceAfterVAT,
    required this.uomEntry,
    this.taxCode = 'IVA',
    this.discountPercent = 0.0,
    this.shipDate,
    this.warehouseCode,
    this.uDescitemfacil,
    this.uPrecioVenta,
    this.uPrecioItemVenta,
    this.uTfeCodeUMfact = '80',
    this.uTfeNomUMfact = 'FRA',
  });

  Map<String, dynamic> toJson() {
    return {
      'ItemCode': itemCode,
      'Quantity': quantity,
      'PriceAfterVAT': priceAfterVAT,
      'UoMEntry': uomEntry,
      'TaxCode': taxCode,
      'DiscountPercent': discountPercent,
      'ShipDate': shipDate?.toIso8601String(),
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
      itemCode: json['ItemCode'] ?? '',
      quantity: (json['Quantity'] as num?)?.toDouble() ?? 0.0,
      priceAfterVAT: (json['PriceAfterVAT'] as num?)?.toDouble() ?? 0.0,
      uomEntry: json['UoMEntry'] ?? 1,
      taxCode: json['TaxCode'] ?? 'IVA',
      discountPercent: (json['DiscountPercent'] as num?)?.toDouble() ?? 0.0,
      shipDate: json['ShipDate'] != null ? DateTime.parse(json['ShipDate']) : null,
      warehouseCode: json['WarehouseCode'],
      uDescitemfacil: json['U_descitemfacil'],
      uPrecioVenta: (json['U_PrecioVenta'] as num?)?.toDouble(),
      uPrecioItemVenta: (json['U_PrecioItemVenta'] as num?)?.toDouble(),
      uTfeCodeUMfact: json['U_TFE_codUMfact'] ?? '80',
      uTfeNomUMfact: json['U_TFE_nomUMfact'] ?? 'FRA',
    );
  }

  SalesOrderLineDto copyWith({
    String? itemCode,
    double? quantity,
    double? priceAfterVAT,
    int? uomEntry,
    String? taxCode,
    double? discountPercent,
    DateTime? shipDate,
    String? warehouseCode,
    String? uDescitemfacil,
    double? uPrecioVenta,
    double? uPrecioItemVenta,
    String? uTfeCodeUMfact,
    String? uTfeNomUMfact,
  }) {
    return SalesOrderLineDto(
      itemCode: itemCode ?? this.itemCode,
      quantity: quantity ?? this.quantity,
      priceAfterVAT: priceAfterVAT ?? this.priceAfterVAT,
      uomEntry: uomEntry ?? this.uomEntry,
      taxCode: taxCode ?? this.taxCode,
      discountPercent: discountPercent ?? this.discountPercent,
      shipDate: shipDate ?? this.shipDate,
      warehouseCode: warehouseCode ?? this.warehouseCode,
      uDescitemfacil: uDescitemfacil ?? this.uDescitemfacil,
      uPrecioVenta: uPrecioVenta ?? this.uPrecioVenta,
      uPrecioItemVenta: uPrecioItemVenta ?? this.uPrecioItemVenta,
      uTfeCodeUMfact: uTfeCodeUMfact ?? this.uTfeCodeUMfact,
      uTfeNomUMfact: uTfeNomUMfact ?? this.uTfeNomUMfact,
    );
  }

  double get lineTotal => quantity * priceAfterVAT;

  @override
  List<Object?> get props => [
    itemCode, quantity, priceAfterVAT, uomEntry, taxCode, discountPercent,
    shipDate, warehouseCode, uDescitemfacil, uPrecioVenta, uPrecioItemVenta,
    uTfeCodeUMfact, uTfeNomUMfact,
  ];
}