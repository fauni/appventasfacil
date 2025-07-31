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