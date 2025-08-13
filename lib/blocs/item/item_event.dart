import 'package:appventas/models/item/item.dart';
import 'package:equatable/equatable.dart';

abstract class ItemEvent extends Equatable {
  const ItemEvent();

  @override
  List<Object?> get props => [];
}

class ItemSearchRequested extends ItemEvent {
  final String searchTerm;
  final int pageNumber;
  final int pageSize;

  const ItemSearchRequested({
    this.searchTerm = '',
    this.pageNumber = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [searchTerm, pageNumber, pageSize];
}

class ItemLoadMoreRequested extends ItemEvent {
  final String searchTerm;
  final int currentPage;
  final int pageSize;

  const ItemLoadMoreRequested({
    required this.searchTerm,
    required this.currentPage,
    required this.pageSize,
  });

  @override
  List<Object?> get props => [searchTerm, currentPage, pageSize];
}

class ItemSelected extends ItemEvent {
  final Item item;

  const ItemSelected(this.item);

  @override
  List<Object> get props => [item];
}

class ItemAutocompleteRequested extends ItemEvent {
  final String term;

  const ItemAutocompleteRequested(this.term);

  @override
  List<Object> get props => [term];
}

class ItemByCodeRequested extends ItemEvent {
  final String itemCode;

  const ItemByCodeRequested(this.itemCode);

  @override
  List<Object> get props => [itemCode];
}

class ItemSearchCleared extends ItemEvent {}

class ItemSelectionCleared extends ItemEvent {}

// Nuevos eventos para manejo de stock
class ItemStockRequested extends ItemEvent {
  final String itemCode;

  const ItemStockRequested(this.itemCode);

  @override
  List<Object> get props => [itemCode];
}

class ItemStockValidationRequested extends ItemEvent {
  final String itemCode;
  final double requiredQuantity;

  const ItemStockValidationRequested({
    required this.itemCode,
    required this.requiredQuantity,
  });

  @override
  List<Object> get props => [itemCode, requiredQuantity];
}

class ItemLowStockRequested extends ItemEvent {
  final double minStock;
  final int pageSize;

  const ItemLowStockRequested({
    this.minStock = 10.0,
    this.pageSize = 50,
  });

  @override
  List<Object> get props => [minStock, pageSize];
}

class ItemOutOfStockRequested extends ItemEvent {
  final int pageSize;

  const ItemOutOfStockRequested({this.pageSize = 50});

  @override
  List<Object> get props => [pageSize];
}

class ItemWarehouseStockRequested extends ItemEvent {
  final String itemCode;

  const ItemWarehouseStockRequested(this.itemCode);

  @override
  List<Object> get props => [itemCode];
}