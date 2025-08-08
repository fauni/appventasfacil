// lib/models/sales_order/sales_order_response.dart
class SalesOrderResponse {
  final int docEntry;
  final String docNum;
  final String message;
  final bool success;

  SalesOrderResponse({
    required this.docEntry,
    required this.docNum,
    required this.message,
    required this.success,
  });

  factory SalesOrderResponse.fromJson(Map<String, dynamic> json) {
    return SalesOrderResponse(
      docEntry: json['DocEntry'],
      docNum: json['DocNum'],
      message: json['Message'],
      success: json['Success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'DocEntry': docEntry,
      'DocNum': docNum,
      'Message': message,
      'Success': success,
    };
  }
}