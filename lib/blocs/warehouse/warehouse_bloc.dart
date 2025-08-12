// lib/blocs/warehouse/warehouse_bloc.dart
import 'package:appventas/models/warehouse/warehouse.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/warehouse_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'warehouse_event.dart';
import 'warehouse_state.dart';

class WarehouseBloc extends Bloc<WarehouseEvent, WarehouseState> {
  Warehouse? _selectedWarehouse;

  WarehouseBloc() : super(const WarehouseInitial()) {
    on<WarehousesLoadRequested>(_onLoadRequested);
    on<WarehousesSearchRequested>(_onSearchRequested);
    on<WarehousesSearchTermChanged>(_onSearchTermChanged);
    on<WarehousesLoadMoreRequested>(_onLoadMoreRequested);
    on<WarehousesRefreshRequested>(_onRefreshRequested);
    on<WarehouseByCodeRequested>(_onByCodeRequested);
    on<WarehouseSelectedEvent>(_onWarehouseSelected);
    on<WarehouseSelectionCleared>(_onSelectionCleared);
  }

  Warehouse? get selectedWarehouse => _selectedWarehouse;

  Future<void> _onLoadRequested(
    WarehousesLoadRequested event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(const WarehouseLoading());
    try {
      final warehouses = await WarehouseService.getAllWarehouses();
      
      if (warehouses.isEmpty) {
        emit(const WarehouseEmpty('No se encontraron almacenes activos'));
      } else {
        emit(WarehousesLoaded(warehouses));
      }
    } on UnauthorizedException {
      emit(const WarehouseError('Sesión expirada. Por favor, inicie sesión nuevamente.'));
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    WarehousesSearchRequested event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(const WarehouseLoading());
    try {
      final response = await WarehouseService.searchWarehouses(
        searchTerm: event.request.searchTerm,
        pageSize: event.request.pageSize,
        pageNumber: event.request.pageNumber,
      );
      
      if (response.warehouses.isEmpty) {
        emit(const WarehouseEmpty('No se encontraron almacenes con los criterios de búsqueda'));
      } else {
        emit(WarehousesSearchLoaded(response, event.request));
      }
    } on UnauthorizedException {
      emit(const WarehouseError('Sesión expirada. Por favor, inicie sesión nuevamente.'));
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  Future<void> _onSearchTermChanged(
    WarehousesSearchTermChanged event,
    Emitter<WarehouseState> emit,
  ) async {
    // Debounce la búsqueda para evitar demasiadas llamadas a la API
    await Future.delayed(const Duration(milliseconds: 300));
    
    final request = WarehouseSearchRequest(
      searchTerm: event.searchTerm,
      pageSize: 20,
      pageNumber: 1,
    );
    
    add(WarehousesSearchRequested(request));
  }

  Future<void> _onLoadMoreRequested(
    WarehousesLoadMoreRequested event,
    Emitter<WarehouseState> emit,
  ) async {
    final currentState = state;
    if (currentState is WarehousesSearchLoaded && 
        currentState.response.hasNextPage) {
      
      emit(WarehouseLoadingMore(currentState.response));
      
      try {
        final nextPageRequest = currentState.request.copyWith(
          pageNumber: currentState.request.pageNumber + 1,
        );
        
        final response = await WarehouseService.searchWarehouses(
          searchTerm: nextPageRequest.searchTerm,
          pageSize: nextPageRequest.pageSize,
          pageNumber: nextPageRequest.pageNumber,
        );
        
        // Combinar resultados
        final allWarehouses = [
          ...currentState.response.warehouses,
          ...response.warehouses,
        ];
        
        final combinedResponse = WarehouseSearchResponse(
          warehouses: allWarehouses,
          totalCount: response.totalCount,
          pageNumber: response.pageNumber,
          pageSize: response.pageSize,
          totalPages: response.totalPages,
        );
        
        emit(WarehousesSearchLoaded(combinedResponse, nextPageRequest));
      } on UnauthorizedException {
        emit(const WarehouseError('Sesión expirada. Por favor, inicie sesión nuevamente.'));
      } catch (e) {
        emit(WarehouseError(e.toString()));
      }
    }
  }

  Future<void> _onRefreshRequested(
    WarehousesRefreshRequested event,
    Emitter<WarehouseState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is WarehousesSearchLoaded) {
      // Refrescar búsqueda actual
      add(WarehousesSearchRequested(
        currentState.request.copyWith(pageNumber: 1)
      ));
    } else {
      // Refrescar lista completa
      add(const WarehousesLoadRequested());
    }
  }

  Future<void> _onByCodeRequested(
    WarehouseByCodeRequested event,
    Emitter<WarehouseState> emit,
  ) async {
    emit(const WarehouseLoading());
    try {
      final warehouse = await WarehouseService.getWarehouseByCode(event.whsCode);
      emit(WarehouseDetailLoaded(warehouse));
    } on UnauthorizedException {
      emit(const WarehouseError('Sesión expirada. Por favor, inicie sesión nuevamente.'));
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  void _onWarehouseSelected(
    WarehouseSelectedEvent event,
    Emitter<WarehouseState> emit,
  ) {
    _selectedWarehouse = event.warehouse;
    emit(WarehouseSelected(event.warehouse));
  }

  void _onSelectionCleared(
    WarehouseSelectionCleared event,
    Emitter<WarehouseState> emit,
  ) {
    _selectedWarehouse = null;
    emit(const WarehouseInitial());
  }
}