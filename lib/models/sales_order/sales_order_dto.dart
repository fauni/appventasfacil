// lib/models/sales_order/sales_order_dto.dart
import 'package:appventas/models/sales_order/sales_order_line_dto.dart';

class SalesOrderDto {
  final int? docEntry;
  final DateTime docDate;
  final DateTime docDueDate;
  final String cardCode;
  final String comments;
  final int series;
  final int salesPersonCode;
  final int? contactPersonCode;
  final int paymentGroupCode;
  final List<SalesOrderLineDto> documentLines;
  final String uUsrventafacil;
  final String? uLatitud;
  final String? uLongitud;
  final DateTime uFecharegistroapp;
  final DateTime uHoraregistroapp;
  final String? cardForeignName;
  final String? uCodigocliente;
  final String uLbRazonSocial;
  final String uNit;
  final String uLbNit;

  SalesOrderDto({
    this.docEntry,
    required this.docDate,
    required this.docDueDate,
    required this.cardCode,
    required this.comments,
    required this.series,
    required this.salesPersonCode,
    this.contactPersonCode,
    required this.paymentGroupCode,
    required this.documentLines,
    required this.uUsrventafacil,
    this.uLatitud,
    this.uLongitud,
    required this.uFecharegistroapp,
    required this.uHoraregistroapp,
    this.cardForeignName,
    this.uCodigocliente,
    required this.uLbRazonSocial,
    required this.uNit,
    required this.uLbNit,
  });

  Map<String, dynamic> toJson() {
    return {
      'DocEntry': docEntry,
      'DocDate': docDate.toIso8601String(),
      'DocDueDate': docDueDate.toIso8601String(),
      'CardCode': cardCode,
      'Comments': comments,
      'Series': series,
      'SalesPersonCode': salesPersonCode,
      'ContactPersonCode': contactPersonCode,
      'PaymentGroupCode': paymentGroupCode,
      'DocumentLines': documentLines.map((line) => line.toJson()).toList(),
      'U_usrventafacil': uUsrventafacil,
      'U_latitud': uLatitud,
      'U_longitud': uLongitud,
      'U_fecharegistroapp': uFecharegistroapp.toIso8601String(),
      'U_horaregistroapp': uHoraregistroapp.toIso8601String(),
      'CardForeignName': cardForeignName,
      'U_codigocliente': uCodigocliente,
      'U_LB_RazonSocial': uLbRazonSocial,
      'U_NIT': uNit,
      'U_LB_NIT': uLbNit,
    };
  }

  factory SalesOrderDto.fromJson(Map<String, dynamic> json) {
    return SalesOrderDto(
      docEntry: json['DocEntry'],
      docDate: DateTime.parse(json['DocDate']),
      docDueDate: DateTime.parse(json['DocDueDate']),
      cardCode: json['CardCode'],
      comments: json['Comments'],
      series: json['Series'],
      salesPersonCode: json['SalesPersonCode'],
      contactPersonCode: json['ContactPersonCode'],
      paymentGroupCode: json['PaymentGroupCode'],
      documentLines: (json['DocumentLines'] as List)
          .map((line) => SalesOrderLineDto.fromJson(line))
          .toList(),
      uUsrventafacil: json['U_usrventafacil'],
      uLatitud: json['U_latitud'],
      uLongitud: json['U_longitud'],
      uFecharegistroapp: DateTime.parse(json['U_fecharegistroapp']),
      uHoraregistroapp: DateTime.parse(json['U_horaregistroapp']),
      cardForeignName: json['CardForeignName'],
      uCodigocliente: json['U_codigocliente'],
      uLbRazonSocial: json['U_LB_RazonSocial'],
      uNit: json['U_NIT'],
      uLbNit: json['U_LB_NIT'],
    );
  }
}







