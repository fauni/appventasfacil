// lib/models/sales_order/sales_order.dart
import 'package:appventas/models/sales_order/sales_order_line.dart';

class SalesOrder {
  final int docEntry;
  final String docNum;
  final DateTime docDate;
  final DateTime docDueDate;
  final String cardCode;
  final String cardName;
  final double docTotal;
  final String docStatus;
  final String salesPersonName;
  final String comments;
  final List<SalesOrderLine> lines;

  SalesOrder({
    required this.docEntry,
    required this.docNum,
    required this.docDate,
    required this.docDueDate,
    required this.cardCode,
    required this.cardName,
    required this.docTotal,
    required this.docStatus,
    required this.salesPersonName,
    required this.comments,
    required this.lines,
  });

  factory SalesOrder.fromJson(Map<String, dynamic> json) {
    return SalesOrder(
      docEntry: json['docEntry'],
      docNum: json['docNum'],
      docDate: DateTime.parse(json['docDate']),
      docDueDate: DateTime.parse(json['docDueDate']),
      cardCode: json['cardCode'],
      cardName: json['cardName'],
      docTotal: (json['docTotal'] as num).toDouble(),
      docStatus: json['docStatus'],
      salesPersonName: json['salesPersonName'],
      comments: json['comments'],
      lines: (json['lines'] as List? ?? [])
          .map((line) => SalesOrderLine.fromJson(line))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'docEntry': docEntry,
      'docNum': docNum,
      'docDate': docDate.toIso8601String(),
      'docDueDate': docDueDate.toIso8601String(),
      'cardCode': cardCode,
      'cardName': cardName,
      'docTotal': docTotal,
      'docStatus': docStatus,
      'salesPersonName': salesPersonName,
      'comments': comments,
      'lines': lines.map((line) => line.toJson()).toList(),
    };
  }
}