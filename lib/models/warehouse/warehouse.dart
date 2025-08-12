// lib/models/warehouse/warehouse.dart
import 'package:equatable/equatable.dart';

class Warehouse extends Equatable {
  final String whsCode;
  final String whsName;

  const Warehouse({
    required this.whsCode,
    required this.whsName,
  });

  @override
  List<Object?> get props => [whsCode, whsName];

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      whsCode: json['whsCode'] ?? '',
      whsName: json['whsName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whsCode': whsCode,
      'whsName': whsName,
    };
  }

  @override
  String toString() => '$whsCode - $whsName';

  String get displayName => '$whsCode - $whsName';
}

class WarehouseSearchRequest extends Equatable {
  final String searchTerm;
  final int pageSize;
  final int pageNumber;

  const WarehouseSearchRequest({
    this.searchTerm = '',
    this.pageSize = 20,
    this.pageNumber = 1,
  });

  @override
  List<Object?> get props => [searchTerm, pageSize, pageNumber];

  Map<String, String> toQueryParams() {
    return {
      'searchTerm': searchTerm,
      'pageSize': pageSize.toString(),
      'pageNumber': pageNumber.toString(),
    };
  }

  WarehouseSearchRequest copyWith({
    String? searchTerm,
    int? pageSize,
    int? pageNumber,
  }) {
    return WarehouseSearchRequest(
      searchTerm: searchTerm ?? this.searchTerm,
      pageSize: pageSize ?? this.pageSize,
      pageNumber: pageNumber ?? this.pageNumber,
    );
  }
}

class WarehouseSearchResponse extends Equatable {
  final List<Warehouse> warehouses;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const WarehouseSearchResponse({
    required this.warehouses,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [warehouses, totalCount, pageNumber, pageSize, totalPages];

  factory WarehouseSearchResponse.fromJson(Map<String, dynamic> json) {
    return WarehouseSearchResponse(
      warehouses: (json['warehouses'] as List<dynamic>?)
          ?.map((item) => Warehouse.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  bool get hasNextPage => pageNumber < totalPages;
  bool get hasPreviousPage => pageNumber > 1;
}