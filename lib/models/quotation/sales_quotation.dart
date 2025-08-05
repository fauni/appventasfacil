// lib/models/sales_quotation.dart
import 'package:appventas/models/quotation/sales_quotation_line.dart';

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
  final String? slpName;
  final double docTotal;
  final String? uVfTiempoEntrega;
  final String? uVfValidezOferta;
  final String? uVfFormaPago;
  final String? uVfTiempoEntregaName;
  final String? uVfValidezOfertaName;
  final String? uVfFormaPagoName;
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
    this.slpName,
    required this.docTotal,
    this.uVfTiempoEntrega,
    this.uVfValidezOferta,
    this.uVfFormaPago,
    this.uVfTiempoEntregaName,
    this.uVfValidezOfertaName,
    this.uVfFormaPagoName,
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
      slpName: json['slpName'],
      docTotal: json['docTotal'].toDouble(),
      uVfTiempoEntrega: json['u_VF_TiempoEntrega'],
      uVfValidezOferta: json['u_VF_ValidezOferta'],
      uVfFormaPago: json['u_VF_FormaPago'],
      uVfTiempoEntregaName: json['u_VF_TiempoEntregaName'],
      uVfValidezOfertaName: json['u_VF_ValidezOfertaName'],
      uVfFormaPagoName: json['u_VF_FormaPagoName'],
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
      'slpName': slpName,
      'docTotal': docTotal,
      'u_VF_TiempoEntrega': uVfTiempoEntrega,
      'u_VF_ValidezOferta': uVfValidezOferta,
      'u_VF_FormaPago': uVfFormaPago,
      'u_VF_TiempoEntregaName': uVfTiempoEntregaName,
      'u_VF_ValidezOfertaName': uVfValidezOfertaName,
      'u_VF_FormaPagoName': uVfFormaPagoName,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}