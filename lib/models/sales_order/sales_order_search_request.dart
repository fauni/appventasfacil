import 'package:appventas/models/sales_order/sales_order.dart';
import 'package:equatable/equatable.dart';

class SalesOrderSearchRequest extends Equatable {
  final String searchTerm;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? cardCode;
  final int? slpCode;
  final String? docStatus;
  final int pageSize;
  final int pageNumber;

  const SalesOrderSearchRequest({
    this.searchTerm = '',
    this.dateFrom,
    this.dateTo,
    this.cardCode,
    this.slpCode,
    this.docStatus,
    this.pageSize = 20,
    this.pageNumber = 1,
  });

  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};
    
    if (searchTerm.isNotEmpty) params['searchTerm'] = searchTerm;
    if (dateFrom != null) params['dateFrom'] = dateFrom!.toIso8601String();
    if (dateTo != null) params['dateTo'] = dateTo!.toIso8601String();
    if (cardCode != null) params['cardCode'] = cardCode;
    if (slpCode != null) params['slpCode'] = slpCode.toString();
    if (docStatus != null) params['docStatus'] = docStatus;
    params['pageSize'] = pageSize.toString();
    params['pageNumber'] = pageNumber.toString();
    
    return params;
  }

  SalesOrderSearchRequest copyWith({
    String? searchTerm,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? cardCode,
    int? slpCode,
    String? docStatus,
    int? pageSize,
    int? pageNumber,
  }) {
    return SalesOrderSearchRequest(
      searchTerm: searchTerm ?? this.searchTerm,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      cardCode: cardCode ?? this.cardCode,
      slpCode: slpCode ?? this.slpCode,
      docStatus: docStatus ?? this.docStatus,
      pageSize: pageSize ?? this.pageSize,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }

  @override
  List<Object?> get props => [
    searchTerm, dateFrom, dateTo, cardCode, slpCode, 
    docStatus, pageSize, pageNumber,
  ];
}


class SalesOrderSearchResponse extends Equatable {
  final List<SalesOrder> orders;
  final int totalRecords;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const SalesOrderSearchResponse({
    required this.orders,
    required this.totalRecords,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory SalesOrderSearchResponse.fromJson(Map<String, dynamic> json) {
    return SalesOrderSearchResponse(
      orders: (json['orders'] as List<dynamic>?)
          ?.map((order) => SalesOrder.fromJson(order))
          .toList() ?? [],
      totalRecords: json['totalRecords'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  bool get hasNextPage => pageNumber < totalPages;
  bool get hasPreviousPage => pageNumber > 1;

  @override
  List<Object?> get props => [orders, totalRecords, pageNumber, pageSize, totalPages];
}