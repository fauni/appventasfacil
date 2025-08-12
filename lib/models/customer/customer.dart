// lib/models/customer.dart
import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String cardCode;
  final String cardName;
  final String cardFName;
  final String cardType;
  final int groupCode;
  final String phone1;
  final String licTradNum;
  final String currency;
  final int slpCode;
  final int listNum;
  final int groupNum;
  final String pymntGroup;

  const Customer({
    required this.cardCode,
    required this.cardName,
    required this.cardFName,
    required this.cardType,
    required this.groupCode,
    required this.phone1,
    required this.licTradNum,
    required this.currency,
    required this.slpCode,
    required this.listNum,
    this.groupNum = 0,
    this.pymntGroup = '',
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      cardCode: json['cardCode'] ?? '',
      cardName: json['cardName'] ?? '',
      cardFName: json['cardFName'] ?? '',
      cardType: json['cardType'] ?? '',
      groupCode: json['groupCode'] ?? 0,
      phone1: json['phone1'] ?? '',
      licTradNum: json['licTradNum'] ?? '',
      currency: json['currency'] ?? '',
      slpCode: json['slpCode'] ?? 0,
      listNum: json['listNum'] ?? 0,
      groupNum: json['groupNum'] ?? 0,
      pymntGroup: json['pymntGroup'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardCode': cardCode,
      'cardName': cardName,
      'cardFName': cardFName,
      'cardType': cardType,
      'groupCode': groupCode,
      'phone1': phone1,
      'licTradNum': licTradNum,
      'currency': currency,
      'slpCode': slpCode,
      'listNum': listNum,
      'groupNum': groupNum,
      'pymntGroup': pymntGroup,
    };
  }

  String get displayName => cardFName.isNotEmpty ? cardFName : cardName;
  String get displayText => '$cardCode - $displayName';

  @override
  List<Object?> get props => [
    cardCode,
    cardName,
    cardFName,
    cardType,
    groupCode,
    phone1,
    licTradNum,
    currency,
    slpCode,
    listNum,
    groupNum,
    pymntGroup,
  ];
}

class CustomerSearchRequest extends Equatable {
  final String searchTerm;
  final int pageSize;
  final int pageNumber;

  const CustomerSearchRequest({
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

class CustomerSearchResponse extends Equatable {
  final List<Customer> customers;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const CustomerSearchResponse({
    required this.customers,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory CustomerSearchResponse.fromJson(Map<String, dynamic> json) {
    return CustomerSearchResponse(
      customers: (json['customers'] as List<dynamic>?)
          ?.map((customer) => Customer.fromJson(customer))
          .toList() ?? [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasMorePages => pageNumber < totalPages;

  @override
  List<Object?> get props => [customers, totalCount, pageNumber, pageSize, totalPages];
}

class CustomerAutocomplete extends Equatable {
  final String cardCode;
  final String cardName;
  final String cardFName;
  final String displayText;

  const CustomerAutocomplete({
    required this.cardCode,
    required this.cardName,
    required this.cardFName,
    required this.displayText,
  });

  factory CustomerAutocomplete.fromJson(Map<String, dynamic> json) {
    return CustomerAutocomplete(
      cardCode: json['cardCode'] ?? '',
      cardName: json['cardName'] ?? '',
      cardFName: json['cardFName'] ?? '',
      displayText: json['displayText'] ?? '',
    );
  }

  @override
  List<Object?> get props => [cardCode, cardName, cardFName, displayText];
}