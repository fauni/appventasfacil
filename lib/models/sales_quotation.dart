// lib/models/sales_quotation.dart
import 'package:appventas/models/sales_quotation_line.dart';

class SalesQuotation {
  final int? docEntry;
  final String? docNum;
  final DateTime docDate;
  final DateTime taxDate;
  final String cardCode;
  final String cardName;
  final String? uLbRazonSocial;
  final String? uNit;
  final String? comments;
  final String? slpCode;
  final double docTotal;
  final String? uVfTiempoEntrega;
  final String? uVfValidezOferta;
  final String? uVfFormaPago;
  final List<SalesQuotationLine> lines;

  SalesQuotation({
    this.docEntry,
    this.docNum,
    required this.docDate,
    required this.taxDate,
    required this.cardCode,
    required this.cardName,
    this.uLbRazonSocial,
    this.uNit,
    this.comments,
    this.slpCode,
    required this.docTotal,
    this.uVfTiempoEntrega,
    this.uVfValidezOferta,
    this.uVfFormaPago,
    this.lines = const [],
  });

  factory SalesQuotation.fromJson(Map<String, dynamic> json) {
    return SalesQuotation(
      docEntry: json['docEntry'],
      docNum: json['docNum'],
      docDate: DateTime.parse(json['docDate']),
      taxDate: DateTime.parse(json['taxDate']),
      cardCode: json['cardCode'],
      cardName: json['cardName'],
      uLbRazonSocial: json['u_LB_RazonSocial'],
      uNit: json['u_NIT'],
      comments: json['comments'],
      slpCode: json['slpCode'],
      docTotal: json['docTotal'].toDouble(),
      uVfTiempoEntrega: json['u_VF_TiempoEntrega'],
      uVfValidezOferta: json['u_VF_ValidezOferta'],
      uVfFormaPago: json['u_VF_FormaPago'],
      lines: (json['lines'] as List?)
          ?.map((line) => SalesQuotationLine.fromJson(line))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docDate': docDate.toIso8601String(),
      'taxDate': taxDate.toIso8601String(),
      'cardCode': cardCode,
      'cardName': cardName,
      'u_LB_RazonSocial': uLbRazonSocial,
      'u_NIT': uNit,
      'comments': comments,
      'slpCode': slpCode,
      'docTotal': docTotal,
      'u_VF_TiempoEntrega': uVfTiempoEntrega,
      'u_VF_ValidezOferta': uVfValidezOferta,
      'u_VF_FormaPago': uVfFormaPago,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}