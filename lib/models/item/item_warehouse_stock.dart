import 'package:equatable/equatable.dart';

class ItemWarehouseStock extends Equatable {
  final String whsCode;
  final String whsName;
  final double onHand;
  final double isCommited;
  final double onOrder;
  final double available;

  const ItemWarehouseStock({
    required this.whsCode,
    required this.whsName,
    required this.onHand,
    required this.isCommited,
    required this.onOrder,
    required this.available,
  });

  factory ItemWarehouseStock.fromJson(Map<String, dynamic> json) {
    return ItemWarehouseStock(
      whsCode: json['whsCode'] ?? '',
      whsName: json['whsName'] ?? '',
      onHand: (json['onHand'] as num?)?.toDouble() ?? 0.0,
      isCommited: (json['isCommited'] as num?)?.toDouble() ?? 0.0,
      onOrder: (json['onOrder'] as num?)?.toDouble() ?? 0.0,
      available: (json['available'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'whsCode': whsCode,
      'whsName': whsName,
      'onHand': onHand,
      'isCommited': isCommited,
      'onOrder': onOrder,
      'available': available,
    };
  }

  String get displayName => '$whsCode - $whsName';
  String get onHandDisplay => onHand.toStringAsFixed(2);
  String get isCommitedDisplay => isCommited.toStringAsFixed(2);
  String get onOrderDisplay => onOrder.toStringAsFixed(2);
  String get availableDisplay => available.toStringAsFixed(2);

  @override
  List<Object?> get props => [whsCode, whsName, onHand, isCommited, onOrder, available];
}

class ItemWarehouseStockResponse extends Equatable {
  final String itemCode;
  final String itemName;
  final List<ItemWarehouseStock> warehouseStocks;
  final double totalOnHand;
  final double totalIsCommited;
  final double totalOnOrder;
  final double totalAvailable;

  const ItemWarehouseStockResponse({
    required this.itemCode,
    required this.itemName,
    required this.warehouseStocks,
    required this.totalOnHand,
    required this.totalIsCommited,
    required this.totalOnOrder,
    required this.totalAvailable,
  });

  factory ItemWarehouseStockResponse.fromJson(Map<String, dynamic> json) {
    return ItemWarehouseStockResponse(
      itemCode: json['itemCode'] ?? '',
      itemName: json['itemName'] ?? '',
      warehouseStocks: (json['warehouseStocks'] as List<dynamic>?)
          ?.map((item) => ItemWarehouseStock.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      totalOnHand: (json['totalOnHand'] as num?)?.toDouble() ?? 0.0,
      totalIsCommited: (json['totalIsCommited'] as num?)?.toDouble() ?? 0.0,
      totalOnOrder: (json['totalOnOrder'] as num?)?.toDouble() ?? 0.0,
      totalAvailable: (json['totalAvailable'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get totalOnHandDisplay => totalOnHand.toStringAsFixed(2);
  String get totalIsCommitedDisplay => totalIsCommited.toStringAsFixed(2);
  String get totalOnOrderDisplay => totalOnOrder.toStringAsFixed(2);
  String get totalAvailableDisplay => totalAvailable.toStringAsFixed(2);

  @override
  List<Object?> get props => [
    itemCode, itemName, warehouseStocks, 
    totalOnHand, totalIsCommited, totalOnOrder, totalAvailable
  ];
}