// lib/blocs/customer/customer_bloc.dart
import 'package:appventas/services/http_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/models/customer/customer.dart';
import 'package:appventas/services/customer_service.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  Customer? _selectedCustomer;
  
  Customer? get selectedCustomer => _selectedCustomer;

  CustomerBloc() : super(CustomerInitial()) {
    on<CustomerSearchRequested>(_onCustomerSearchRequested);
    on<CustomerLoadMoreRequested>(_onCustomerLoadMoreRequested);
    on<CustomerSelected>(_onCustomerSelected);
    on<CustomerAutocompleteRequested>(_onCustomerAutocompleteRequested);
    on<CustomerByCodeRequested>(_onCustomerByCodeRequested);
    on<CustomerSearchCleared>(_onCustomerSearchCleared);
    on<CustomerSelectionCleared>(_onCustomerSelectionCleared);
  }

  Future<void> _onCustomerSearchRequested(
    CustomerSearchRequested event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      
      final response = await CustomerService.searchCustomers(
        searchTerm: event.searchTerm,
        pageNumber: event.pageNumber,
        pageSize: event.pageSize,
      );

      emit(CustomerSearchLoaded(
        response: response,
        searchTerm: event.searchTerm,
      ));
    } on UnauthorizedException catch (e) {
      // No emitir error - el HttpClient ya manejó la redirección
      // El usuario será redirigido al login automáticamente
      print('🔓 Sesión expirada detectada en CustomerBloc');
    } catch (e) {
      emit(CustomerError('Error al buscar clientes: ${e.toString()}'));
    }
  }

  Future<void> _onCustomerLoadMoreRequested(
    CustomerLoadMoreRequested event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      if (state is CustomerSearchLoaded) {
        final currentState = state as CustomerSearchLoaded;
        
        emit(CustomerLoadingMore(
          currentCustomers: currentState.response.customers,
          currentPage: currentState.response.pageNumber,
          searchTerm: event.searchTerm,
        ));

        final response = await CustomerService.searchCustomers(
          searchTerm: event.searchTerm,
          pageNumber: event.currentPage + 1,
          pageSize: event.pageSize,
        );

        final allCustomers = [
          ...currentState.response.customers,
          ...response.customers,
        ];

        final newResponse = CustomerSearchResponse(
          customers: allCustomers,
          totalCount: response.totalCount,
          pageNumber: response.pageNumber,
          pageSize: response.pageSize,
          totalPages: response.totalPages,
        );

        emit(CustomerSearchLoadedMore(
          response: newResponse,
          searchTerm: event.searchTerm,
          allCustomers: allCustomers,
        ));
      } else if (state is CustomerSearchLoadedMore) {
        final currentState = state as CustomerSearchLoadedMore;
        
        emit(CustomerLoadingMore(
          currentCustomers: currentState.allCustomers,
          currentPage: currentState.response.pageNumber,
          searchTerm: event.searchTerm,
        ));

        final response = await CustomerService.searchCustomers(
          searchTerm: event.searchTerm,
          pageNumber: event.currentPage + 1,
          pageSize: event.pageSize,
        );

        final allCustomers = [
          ...currentState.allCustomers,
          ...response.customers,
        ];

        final newResponse = CustomerSearchResponse(
          customers: allCustomers,
          totalCount: response.totalCount,
          pageNumber: response.pageNumber,
          pageSize: response.pageSize,
          totalPages: response.totalPages,
        );

        emit(CustomerSearchLoadedMore(
          response: newResponse,
          searchTerm: event.searchTerm,
          allCustomers: allCustomers,
        ));
      }
    } on UnauthorizedException catch (e) {
      // Redirección automática - no emitir error
      print('🔓 Sesión expirada detectada en load more');
    } catch (e) {
      emit(CustomerError('Error al cargar más clientes: ${e.toString()}'));
    }
  }

  Future<void> _onCustomerAutocompleteRequested(
    CustomerAutocompleteRequested event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      if (event.term.isEmpty) {
        emit(const CustomerAutocompleteLoaded(suggestions: [], term: ''));
        return;
      }

      final suggestions = await CustomerService.getCustomersAutocomplete(event.term);
      
      emit(CustomerAutocompleteLoaded(
        suggestions: suggestions,
        term: event.term,
      ));
    } on UnauthorizedException catch (e) {
      // Redirección automática
      print('🔓 Sesión expirada detectada en autocomplete');
    } catch (e) {
      emit(CustomerError('Error en autocompletado: ${e.toString()}'));
    }
  }

  Future<void> _onCustomerByCodeRequested(
    CustomerByCodeRequested event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      emit(CustomerLoading());
      
      final customer = await CustomerService.getCustomerByCode(event.cardCode);
      
      emit(CustomerDetailLoaded(customer));
    } on UnauthorizedException catch (e) {
      // Redirección automática
      print('🔓 Sesión expirada detectada en get by code');
    } catch (e) {
      emit(CustomerError('Cliente no encontrado: ${e.toString()}'));
    }
  }

  Future<void> _onCustomerSelected(
    CustomerSelected event,
    Emitter<CustomerState> emit,
  ) async {
    _selectedCustomer = event.customer;
    emit(CustomerSelectedState(event.customer));
  }

  void _onCustomerSearchCleared(
    CustomerSearchCleared event,
    Emitter<CustomerState> emit,
  ) {
    emit(CustomerInitial());
  }

  void _onCustomerSelectionCleared(
    CustomerSelectionCleared event,
    Emitter<CustomerState> emit,
  ) {
    _selectedCustomer = null;
    emit(CustomerInitial());
  }
}