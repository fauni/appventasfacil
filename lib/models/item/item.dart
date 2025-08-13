import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String itemCode;
  final String itemName;
  final int ugpEntry;
  final double stock;

  const Item({
    required this.itemCode,
    required this.itemName,
    required this.ugpEntry,
    required this.stock
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      ugpEntry: json['ugpEntry'] ?? 0,
      stock: (json['stock'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'itemName': itemName,
      'ugpEntry': ugpEntry,
      'stock': stock,
    };
  }

  String get displayName => itemName.isNotEmpty ? itemName : itemCode;
  String get displayText => '$itemCode - $displayName';
  String get stockDisplay => stock.toStringAsFixed(2);
  bool get hasStock => stock > 0;


  @override
  List<Object?> get props => [itemCode, itemName, ugpEntry, stock];
}

class ItemSearchRequest extends Equatable {
  final String searchTerm;
  final int pageSize;
  final int pageNumber;

  const ItemSearchRequest({
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

class ItemSearchResponse extends Equatable {
  final List<Item> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;

  const ItemSearchResponse({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
  });

  factory ItemSearchResponse.fromJson(Map<String, dynamic> json) {
    return ItemSearchResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => Item.fromJson(item))
          .toList() ?? [],
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 20,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasMorePages => pageNumber < totalPages;

  @override
  List<Object?> get props => [items, totalCount, pageNumber, pageSize, totalPages];
}

class ItemAutocomplete extends Equatable {
  final String itemCode;
  final String itemName;
  final String displayText;
  final int ugpEntry;
  final double stock;

  const ItemAutocomplete({
    required this.itemCode,
    required this.itemName,
    required this.displayText,
    required this.ugpEntry,
    required this.stock
  });

  factory ItemAutocomplete.fromJson(Map<String, dynamic> json) {
    return ItemAutocomplete(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      displayText: json['displayText'] ?? '',
      ugpEntry: json['ugpEntry'] ?? 0,
      stock: (json['stock'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get stockDisplay => stock.toStringAsFixed(2);
  bool get hasStock => stock > 0;
  @override
  List<Object?> get props => [itemCode, itemName, displayText, ugpEntry, stock];
}
