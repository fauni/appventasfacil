// lib/blocs/sales_order/sales_order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appventas/services/sales_order_service.dart';
import 'sales_order_event.dart';
import 'sales_order_state.dart';

class SalesOrderBloc extends Bloc<SalesOrderEvent, SalesOrderState> {
  SalesOrderBloc() : super(SalesOrderInitial()) {
    on<SalesOrderLoadRequested>(_onLoadRequested);
    on<SalesOrderCreateRequested>(_onCreateRequested);
    on<SalesOrderByIdRequested>(_onByIdRequested);
    on<SalesOrderReset>(_onReset);
  }

  Future<void> _onLoadRequested(
    SalesOrderLoadRequested event,
    Emitter<SalesOrderState> emit,
  ) async {
    emit(SalesOrderLoading());
    try {
      final salesOrders = await SalesOrderService.getSalesOrders();
      emit(SalesOrderLoaded(salesOrders));
    } catch (e) {
      emit(SalesOrderError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    SalesOrderCreateRequested event,
    Emitter<SalesOrderState> emit,
  ) async {
    emit(SalesOrderLoading());
    try {
      final response = await SalesOrderService.createSalesOrder(event.salesOrderDto);
      emit(SalesOrderCreated(response));
    } catch (e) {
      emit(SalesOrderError(e.toString()));
    }
  }

  Future<void> _onByIdRequested(
    SalesOrderByIdRequested event,
    Emitter<SalesOrderState> emit,
  ) async {
    emit(SalesOrderLoading());
    try {
      final salesOrder = await SalesOrderService.getSalesOrderById(event.docEntry);
      if (salesOrder != null) {
        emit(SalesOrderDetailLoaded(salesOrder));
      } else {
        emit(const SalesOrderError('Orden de venta no encontrada'));
      }
    } catch (e) {
      emit(SalesOrderError(e.toString()));
    }
  }

  void _onReset(
    SalesOrderReset event,
    Emitter<SalesOrderState> emit,
  ) {
    emit(SalesOrderInitial());
  }
}