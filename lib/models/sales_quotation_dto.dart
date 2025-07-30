// lib/models/sales_quotation_dto.dart
import 'package:equatable/equatable.dart';

class SalesQuotationDto extends Equatable {
  final String cardCode;
  final String comments;
  final int salesPersonCode;
  final String uUsrventafacil;
  final String? uLatitud;
  final String? uLongitud;
  final String uVfTiempoEntrega;
  final String uVfValidezOferta;
  final String uVfFormaPago;
  final DateTime uFecharegistroapp;
  final DateTime uHoraregistroapp;
  final List<SalesQuotationLineDto> documentLines;

  const SalesQuotationDto({
    required this.cardCode,
    required this.comments,
    required this.salesPersonCode,
    required this.uUsrventafacil,
    this.uLatitud,
    this.uLongitud,
    required this.uVfTiempoEntrega,
    required this.uVfValidezOferta,
    required this.uVfFormaPago,
    required this.uFecharegistroapp,
    required this.uHoraregistroapp,
    required this.documentLines,
  });

  Map<String, dynamic> toJson() {
    return {
      'CardCode': cardCode,
      'Comments': comments,
      'SalesPersonCode': salesPersonCode,
      'U_usrventafacil': uUsrventafacil,
      'U_latitud': uLatitud,
      'U_longitud': uLongitud,
      'U_VF_TiempoEntrega': uVfTiempoEntrega,
      'U_VF_ValidezOferta': uVfValidezOferta,
      'U_VF_FormaPago': uVfFormaPago,
      'U_fecharegistroapp': uFecharegistroapp.toIso8601String(),
      'U_horaregistroapp': uHoraregistroapp.toIso8601String(),
      'DocumentLines': documentLines.map((line) => line.toJson()).toList(),
    };
  }

  factory SalesQuotationDto.fromJson(Map<String, dynamic> json) {
    return SalesQuotationDto(
      cardCode: json['CardCode'] ?? '',
      comments: json['Comments'] ?? '',
      salesPersonCode: json['SalesPersonCode'] ?? 0,
      uUsrventafacil: json['U_usrventafacil'] ?? '',
      uLatitud: json['U_latitud'],
      uLongitud: json['U_longitud'],
      uVfTiempoEntrega: json['U_VF_TiempoEntrega'] ?? '',
      uVfValidezOferta: json['U_VF_ValidezOferta'] ?? '',
      uVfFormaPago: json['U_VF_FormaPago'] ?? '',
      uFecharegistroapp: DateTime.parse(json['U_fecharegistroapp']),
      uHoraregistroapp: DateTime.parse(json['U_horaregistroapp']),
      documentLines: (json['DocumentLines'] as List<dynamic>?)
          ?.map((line) => SalesQuotationLineDto.fromJson(line))
          .toList() ?? [],
    );
  }

  SalesQuotationDto copyWith({
    String? cardCode,
    String? comments,
    int? salesPersonCode,
    String? uUsrventafacil,
    String? uLatitud,
    String? uLongitud,
    String? uVfTiempoEntrega,
    String? uVfValidezOferta,
    String? uVfFormaPago,
    DateTime? uFecharegistroapp,
    DateTime? uHoraregistroapp,
    List<SalesQuotationLineDto>? documentLines,
  }) {
    return SalesQuotationDto(
      cardCode: cardCode ?? this.cardCode,
      comments: comments ?? this.comments,
      salesPersonCode: salesPersonCode ?? this.salesPersonCode,
      uUsrventafacil: uUsrventafacil ?? this.uUsrventafacil,
      uLatitud: uLatitud ?? this.uLatitud,
      uLongitud: uLongitud ?? this.uLongitud,
      uVfTiempoEntrega: uVfTiempoEntrega ?? this.uVfTiempoEntrega,
      uVfValidezOferta: uVfValidezOferta ?? this.uVfValidezOferta,
      uVfFormaPago: uVfFormaPago ?? this.uVfFormaPago,
      uFecharegistroapp: uFecharegistroapp ?? this.uFecharegistroapp,
      uHoraregistroapp: uHoraregistroapp ?? this.uHoraregistroapp,
      documentLines: documentLines ?? this.documentLines,
    );
  }

  double get totalAmount {
    return documentLines.fold(0.0, (sum, line) => sum + line.lineTotal);
  }

  @override
  List<Object?> get props => [
    cardCode,
    comments,
    salesPersonCode,
    uUsrventafacil,
    uLatitud,
    uLongitud,
    uVfTiempoEntrega,
    uVfValidezOferta,
    uVfFormaPago,
    uFecharegistroapp,
    uHoraregistroapp,
    documentLines,
  ];
}

class SalesQuotationLineDto extends Equatable {
  final String itemCode;
  final double quantity;
  final double priceAfterVAT;
  final int uomEntry;

  const SalesQuotationLineDto({
    required this.itemCode,
    required this.quantity,
    required this.priceAfterVAT,
    required this.uomEntry,
  });

  Map<String, dynamic> toJson() {
    return {
      'ItemCode': itemCode,
      'Quantity': quantity,
      'PriceAfterVAT': priceAfterVAT,
      'UoMEntry': uomEntry,
    };
  }

  factory SalesQuotationLineDto.fromJson(Map<String, dynamic> json) {
    return SalesQuotationLineDto(
      itemCode: json['ItemCode'] ?? '',
      quantity: (json['Quantity'] as num?)?.toDouble() ?? 0.0,
      priceAfterVAT: (json['PriceAfterVAT'] as num?)?.toDouble() ?? 0.0,
      uomEntry: json['UoMEntry'] ?? 1,
    );
  }

  SalesQuotationLineDto copyWith({
    String? itemCode,
    double? quantity,
    double? priceAfterVAT,
    int? uomEntry,
  }) {
    return SalesQuotationLineDto(
      itemCode: itemCode ?? this.itemCode,
      quantity: quantity ?? this.quantity,
      priceAfterVAT: priceAfterVAT ?? this.priceAfterVAT,
      uomEntry: uomEntry ?? this.uomEntry,
    );
  }

  double get lineTotal => quantity * priceAfterVAT;

  @override
  List<Object?> get props => [itemCode, quantity, priceAfterVAT, uomEntry];
}

// Response models for quotation creation
class QuotationCreationResponse extends Equatable {
  final bool success;
  final String message;
  final String? data;

  const QuotationCreationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory QuotationCreationResponse.fromJson(Map<String, dynamic> json) {
    return QuotationCreationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data']?.toString(),
    );
  }

  @override
  List<Object?> get props => [success, message, data];
}