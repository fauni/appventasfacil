import 'package:appventas/services/sales_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/storage_service.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(SalesInitial()) {
    on<SalesLoadRequested>(_onLoadRequested);
    on<SaleCreateFromQuotationRequested>(_onCreateFromQuotationRequested);
  }

  Future<void> _onLoadRequested(
    SalesLoadRequested event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        emit(const SalesError('No authentication token found'));
        return;
      }

      final salesOrders = await SalesService.getSalesOrders(token);
      emit(SalesLoaded(salesOrders));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }

  Future<void> _onCreateFromQuotationRequested(
    SaleCreateFromQuotationRequested event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        emit(const SalesError('No authentication token found'));
        return;
      }

      final saleOrder = await SalesService.createSaleFromQuotation(
        event.quotationDocEntry,
        token,
      );
      emit(SaleCreated(saleOrder));
    } catch (e) {
      emit(SalesError(e.toString()));
    }
  }
}