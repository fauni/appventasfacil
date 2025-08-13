import 'package:appventas/models/item/item.dart';
import 'package:appventas/models/item/item_warehouse_stock.dart';
import 'package:equatable/equatable.dart';

abstract class ItemState extends Equatable {
  const ItemState();

  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemLoadingMore extends ItemState {
  final List<Item> currentItems;
  final int currentPage;
  final String searchTerm;

  const ItemLoadingMore({
    required this.currentItems,
    required this.currentPage,
    required this.searchTerm,
  });

  @override
  List<Object> get props => [currentItems, currentPage, searchTerm];
}

class ItemSearchLoaded extends ItemState {
  final ItemSearchResponse response;
  final String searchTerm;

  const ItemSearchLoaded({
    required this.response,
    required this.searchTerm,
  });

  @override
  List<Object> get props => [response, searchTerm];
}

class ItemSearchLoadedMore extends ItemState {
  final ItemSearchResponse response;
  final String searchTerm;
  final List<Item> allItems;

  const ItemSearchLoadedMore({
    required this.response,
    required this.searchTerm,
    required this.allItems,
  });

  @override
  List<Object> get props => [response, searchTerm, allItems];
}

class ItemDetailLoaded extends ItemState {
  final Item item;

  const ItemDetailLoaded(this.item);

  @override
  List<Object> get props => [item];
}

class ItemAutocompleteLoaded extends ItemState {
  final List<ItemAutocomplete> suggestions;
  final String term;

  const ItemAutocompleteLoaded({
    required this.suggestions,
    required this.term,
  });

  @override
  List<Object> get props => [suggestions, term];
}

class ItemSelectedState extends ItemState {
  final Item item;

  const ItemSelectedState(this.item);

  @override
  List<Object> get props => [item];
}

class ItemError extends ItemState {
  final String message;

  const ItemError(this.message);

  @override
  List<Object> get props => [message];
}

// Nuevos estados para manejo de stock
class ItemStockLoaded extends ItemState {
  final String itemCode;
  final double stock;

  const ItemStockLoaded({
    required this.itemCode,
    required this.stock,
  });

  @override
  List<Object> get props => [itemCode, stock];
}

class ItemStockValidated extends ItemState {
  final String itemCode;
  final double requiredQuantity;
  final double availableStock;
  final bool hasEnoughStock;

  const ItemStockValidated({
    required this.itemCode,
    required this.requiredQuantity,
    required this.availableStock,
    required this.hasEnoughStock,
  });

  @override
  List<Object> get props => [itemCode, requiredQuantity, availableStock, hasEnoughStock];
}

class ItemLowStockLoaded extends ItemState {
  final List<Item> lowStockItems;
  final double minStock;

  const ItemLowStockLoaded({
    required this.lowStockItems,
    required this.minStock,
  });

  @override
  List<Object> get props => [lowStockItems, minStock];
}

class ItemOutOfStockLoaded extends ItemState {
  final List<Item> outOfStockItems;

  const ItemOutOfStockLoaded({
    required this.outOfStockItems,
  });

  @override
  List<Object> get props => [outOfStockItems];
}

// Metodos para obtener el stock de un item por almacen 
class ItemWarehouseStockLoaded extends ItemState {
  final ItemWarehouseStockResponse stockResponse;

  const ItemWarehouseStockLoaded(this.stockResponse);

  @override
  List<Object> get props => [stockResponse];
}

class ItemWarehouseStockLoading extends ItemState {
  final String itemCode;

  const ItemWarehouseStockLoading(this.itemCode);

  @override
  List<Object> get props => [itemCode];
}