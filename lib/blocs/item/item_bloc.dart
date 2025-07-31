import 'package:appventas/models/item/item.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/item_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'item_event.dart';
import 'item_state.dart';

class ItemBloc extends Bloc<ItemEvent, ItemState> {
  Item? _selectedItem;
  
  Item? get selectedItem => _selectedItem;

  ItemBloc() : super(ItemInitial()) {
    on<ItemSearchRequested>(_onItemSearchRequested);
    on<ItemLoadMoreRequested>(_onItemLoadMoreRequested);
    on<ItemSelected>(_onItemSelected);
    on<ItemAutocompleteRequested>(_onItemAutocompleteRequested);
    on<ItemByCodeRequested>(_onItemByCodeRequested);
    on<ItemSearchCleared>(_onItemSearchCleared);
    on<ItemSelectionCleared>(_onItemSelectionCleared);
  }

  Future<void> _onItemSearchRequested(
    ItemSearchRequested event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(ItemLoading());
      
      final response = await ItemService.searchItems(
        searchTerm: event.searchTerm,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );

      emit(ItemSearchLoaded(
        response: response,
        searchTerm: event.searchTerm,
      ));
    } on UnauthorizedException {
      // HttpClient ya manejó la redirección
      print('🔓 Sesión expirada detectada en ItemBloc');
    } catch (e) {
      emit(ItemError('Error al buscar items: ${e.toString()}'));
    }
  }

  Future<void> _onItemLoadMoreRequested(
    ItemLoadMoreRequested event,
    Emitter<ItemState> emit,
  ) async {
    try {
      if (state is ItemSearchLoaded) {
        final currentState = state as ItemSearchLoaded;
        
        emit(ItemLoadingMore(
          currentItems: currentState.response.items,
          currentPage: currentState.response.pageNumber,
          searchTerm: event.searchTerm,
        ));

        final response = await ItemService.searchItems(
          searchTerm: event.searchTerm,
          pageNumber: event.currentPage + 1,
          pageSize: event.pageSize,
        );

        final allItems = [
          ...currentState.response.items,
          ...response.items,
        ];

        final newResponse = ItemSearchResponse(
          items: allItems,
          totalCount: response.totalCount,
          pageNumber: response.pageNumber,
          pageSize: response.pageSize,
          totalPages: response.totalPages,
        );

        emit(ItemSearchLoadedMore(
          response: newResponse,
          searchTerm: event.searchTerm,
          allItems: allItems,
        ));
      } else if (state is ItemSearchLoadedMore) {
        final currentState = state as ItemSearchLoadedMore;
        
        emit(ItemLoadingMore(
          currentItems: currentState.allItems,
          currentPage: currentState.response.pageNumber,
          searchTerm: event.searchTerm,
        ));

        final response = await ItemService.searchItems(
          searchTerm: event.searchTerm,
          pageNumber: event.currentPage + 1,
          pageSize: event.pageSize,
        );

        final allItems = [
          ...currentState.allItems,
          ...response.items,
        ];

        final newResponse = ItemSearchResponse(
          items: allItems,
          totalCount: response.totalCount,
          pageNumber: response.pageNumber,
          pageSize: response.pageSize,
          totalPages: response.totalPages,
        );

        emit(ItemSearchLoadedMore(
          response: newResponse,
          searchTerm: event.searchTerm,
          allItems: allItems,
        ));
      }
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en load more items');
    } catch (e) {
      emit(ItemError('Error al cargar más items: ${e.toString()}'));
    }
  }

  Future<void> _onItemSelected(
    ItemSelected event,
    Emitter<ItemState> emit,
  ) async {
    _selectedItem = event.item;
    emit(ItemSelectedState(event.item));
  }

  Future<void> _onItemAutocompleteRequested(
    ItemAutocompleteRequested event,
    Emitter<ItemState> emit,
  ) async {
    try {
      if (event.term.isEmpty) {
        emit(const ItemAutocompleteLoaded(suggestions: [], term: ''));
        return;
      }

      final suggestions = await ItemService.getItemsAutocomplete(event.term);
      
      emit(ItemAutocompleteLoaded(
        suggestions: suggestions,
        term: event.term,
      ));
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en autocomplete items');
    } catch (e) {
      emit(ItemError('Error en autocompletado: ${e.toString()}'));
    }
  }

  Future<void> _onItemByCodeRequested(
    ItemByCodeRequested event,
    Emitter<ItemState> emit,
  ) async {
    try {
      emit(ItemLoading());
      
      final item = await ItemService.getItemByCode(event.itemCode);
      
      emit(ItemDetailLoaded(item));
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en get item by code');
    } catch (e) {
      emit(ItemError('Item no encontrado: ${e.toString()}'));
    }
  }

  void _onItemSearchCleared(
    ItemSearchCleared event,
    Emitter<ItemState> emit,
  ) {
    emit(ItemInitial());
  }

  void _onItemSelectionCleared(
    ItemSelectionCleared event,
    Emitter<ItemState> emit,
  ) {
    _selectedItem = null;
    emit(ItemInitial());
  }
}