import 'package:appventas/models/sales_order/sales_order_search_request.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/sales_order_service.dart';
import 'package:appventas/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sales_orders_event.dart';
import 'sales_orders_state.dart';

class SalesOrdersBloc extends Bloc<SalesOrdersEvent, SalesOrdersState> {
  SalesOrdersBloc() : super(SalesOrdersInitial()) {
    on<SalesOrdersLoadRequested>(_onLoadRequested);
    on<SalesOrdersSearchRequested>(_onSearchRequested);
    on<SalesOrderDetailRequested>(_onDetailRequested);
    on<SalesOrdersByCustomerRequested>(_onByCustomerRequested);
    on<SalesOrdersBySalesPersonRequested>(_onBySalesPersonRequested);
    on<SalesOrderCreateRequested>(_onCreateRequested);
    on<SalesOrdersRefreshRequested>(_onRefreshRequested);
    on<SalesOrdersLoadMoreRequested>(_onLoadMoreRequested);
    on<SalesOrdersFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoadRequested(
    SalesOrdersLoadRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    emit(SalesOrdersLoading());
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        emit(const SalesOrdersError('No authentication token found'));
        return;
      }

      // Cargar órdenes recientes por defecto
      final request = SalesOrderSearchRequest();
      final response = await SalesOrderService.searchSalesOrders(request);
      
      if (response.orders.isEmpty) {
        emit(const SalesOrdersEmpty('No se encontraron órdenes de venta'));
      } else {
        emit(SalesOrdersLoaded(response, request));
      }
    } on UnauthorizedException {
      // HttpClient ya manejó la redirección
      print('🔓 Sesión expirada detectada en SalesOrdersBloc');
    } catch (e) {
      emit(SalesOrdersError(e.toString()));
    }
  }

  Future<void> _onSearchRequested(
    SalesOrdersSearchRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    emit(SalesOrdersLoading());
    try {
      final response = await SalesOrderService.searchSalesOrders(event.request);
      
      if (response.orders.isEmpty) {
        emit(const SalesOrdersEmpty('No se encontraron órdenes de venta con los criterios especificados'));
      } else {
        emit(SalesOrdersLoaded(response, event.request));
      }
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en SalesOrdersBloc');
    } catch (e) {
      emit(SalesOrdersError(e.toString()));
    }
  }

  Future<void> _onDetailRequested(
    SalesOrderDetailRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    emit(SalesOrderDetailLoading());
    try {
      final order = await SalesOrderService.getSalesOrderById(event.docEntry);
      emit(SalesOrderDetailLoaded(order));
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en SalesOrdersBloc');
    } catch (e) {
      emit(SalesOrdersError(e.toString()));
    }
  }

  Future<void> _onByCustomerRequested(
    SalesOrdersByCustomerRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    emit(SalesOrdersLoading());
    try {
      final orders = await SalesOrderService.getSalesOrdersByCustomer(
        event.cardCode,
        pageSize: event.pageSize,
        pageNumber: event.pageNumber,
      );
      
      if (orders.isEmpty) {
        emit(SalesOrdersEmpty('No se encontraron órdenes para el cliente ${event.cardCode}'));
      } else {
        emit(SalesOrdersByCustomerLoaded(orders, event.cardCode));
      }
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en SalesOrdersBloc');
    } catch (e) {
      emit(SalesOrdersError(e.toString()));
    }
  }

  Future<void> _onBySalesPersonRequested(
    SalesOrdersBySalesPersonRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    emit(SalesOrdersLoading());
    try {
      final orders = await SalesOrderService.getSalesOrdersBySalesPerson(
        event.slpCode,
        pageSize: event.pageSize,
        pageNumber: event.pageNumber,
      );
      
      if (orders.isEmpty) {
        emit(SalesOrdersEmpty('No se encontraron órdenes para el vendedor ${event.slpCode}'));
      } else {
        emit(SalesOrdersBySalesPersonLoaded(orders, event.slpCode));
      }
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en SalesOrdersBloc');
    } catch (e) {
      emit(SalesOrdersError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    SalesOrderCreateRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    emit(SalesOrdersLoading());
    try {
      final result = await SalesOrderService.createSalesOrder(event.orderDto);
      emit(SalesOrderCreated(result));
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en SalesOrdersBloc');
    } catch (e) {
      emit(SalesOrdersError(e.toString()));
    }
  }

  Future<void> _onRefreshRequested(
    SalesOrdersRefreshRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is SalesOrdersLoaded) {
      // Mantener los filtros actuales
      add(SalesOrdersSearchRequested(currentState.currentRequest));
    } else {
      // Cargar por defecto
      add(SalesOrdersLoadRequested());
    }
  }

  Future<void> _onLoadMoreRequested(
    SalesOrdersLoadMoreRequested event,
    Emitter<SalesOrdersState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is SalesOrdersLoaded) {
      // Verificar si hay más páginas
      if (!currentState.response.hasNextPage) return;
      
      emit(SalesOrdersLoadingMore(currentState.response, currentState.currentRequest));
      
      try {
        final nextPageRequest = event.request.copyWith(
          pageNumber: currentState.response.pageNumber + 1,
        );
        
        final newResponse = await SalesOrderService.searchSalesOrders(nextPageRequest);
        
        // Combinar resultados
        final allOrders = [...currentState.response.orders, ...newResponse.orders];
        final combinedResponse = SalesOrderSearchResponse(
          orders: allOrders,
          totalRecords: newResponse.totalRecords,
          pageNumber: newResponse.pageNumber,
          pageSize: newResponse.pageSize,
          totalPages: newResponse.totalPages,
        );
        
        emit(SalesOrdersLoaded(combinedResponse, nextPageRequest));
      } on UnauthorizedException {
        print('🔓 Sesión expirada detectada en SalesOrdersBloc');
      } catch (e) {
        emit(SalesOrdersError(e.toString()));
      }
    }
  }

  Future<void> _onFilterChanged(
    SalesOrdersFilterChanged event,
    Emitter<SalesOrdersState> emit,
  ) async {
    // Resetear a la primera página cuando cambian los filtros
    final newRequest = event.request.copyWith(pageNumber: 1);
    add(SalesOrdersSearchRequested(newRequest));
  }
}