// lib/models/customer.dart
import 'package:equatable/equatable.dart';

class PaymentGroup extends Equatable {
  final int groupNum;
  final String pymntGroup;
  final int listNum;

  const PaymentGroup({
    required this.groupNum,
    required this.pymntGroup,
    required this.listNum
  });

  factory PaymentGroup.fromJson(Map<String, dynamic> json) {
    return PaymentGroup(
      groupNum: json['groupNum'] ?? '',
      pymntGroup: json['pymntGroup'] ?? '',
      listNum: json['listNum'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupNum': groupNum,
      'pymntGroup': pymntGroup,
      'listNum': listNum
    };
  }


  String get displayText => pymntGroup;

  @override
  List<Object?> get props => [
    groupNum,
    pymntGroup,
    listNum
  ];
}

class PaymentGroupSearchRequest extends Equatable {
  final String searchTerm;
  final int pageSize;
  final int pageNumber;

  const PaymentGroupSearchRequest({
    this.searchTerm = '',
    this.pageSize = 20,
    this.pageNumber = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'searchTerm': searchTerm,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
    };
  }

  @override
  List<Object?> get props => [searchTerm, pageSize, pageNumber];
}

class PaymentGroupSearchResponse extends Equatable {
  final List<PaymentGroup> paymentGroups;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const PaymentGroupSearchResponse({
    required this.paymentGroups,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaymentGroupSearchResponse.fromJson(Map<String, dynamic> json) {
    return PaymentGroupSearchResponse(
      paymentGroups: (json['paymentGroups'] as List<dynamic>?)
          ?.map((paymentGroup) => PaymentGroup.fromJson(paymentGroup))
          .toList() ?? [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasMorePages => pageNumber < totalPages;

  @override
  List<Object?> get props => [paymentGroups, totalCount, pageNumber, pageSize, totalPages];
}