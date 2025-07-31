import 'package:appventas/services/quotation_service.dart';
import 'package:appventas/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'quotations_event.dart';
import 'quotations_state.dart';

class QuotationsBloc extends Bloc<QuotationsEvent, QuotationsState> {
  QuotationsBloc() : super(QuotationsInitial()) {
    on<QuotationsLoadRequested>(_onLoadRequested);
    on<QuotationCreateRequested>(_onCreateRequested);
    // on<QuotationConvertToSaleRequested>(_onConvertToSaleRequested);
  }

  Future<void> _onLoadRequested(QuotationsLoadRequested event,Emitter<QuotationsState> emit) async {
    emit(QuotationsLoading());
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        emit(const QuotationsError('No authentication token found'));
        return;
      }

      final quotations = await QuotationService.getQuotations(token);
      emit(QuotationsLoaded(quotations));
    } catch (e) {
      emit(QuotationsError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(QuotationCreateRequested event,Emitter<QuotationsState> emit) async {
    emit(QuotationsLoading());
    try {
      final result = await QuotationService.createQuotation(event.quotationDto);
      emit(QuotationCreated(result));
    } catch (e) {
      emit(QuotationsError(e.toString()));
    }
  }

  // Future<void> _onConvertToSaleRequested(
  //   QuotationConvertToSaleRequested event,
  //   Emitter<QuotationsState> emit,
  // ) async {
  //   emit(QuotationsLoading());
  //   try {
  //     final token = await StorageService.getToken();
  //     if (token == null) {
  //       emit(const QuotationsError('No authentication token found'));
  //       return;
  //     }

  //     final saleOrder = await QuotationService.createSaleFromQuotation(
  //       event.docEntry,
  //       token,
  //     );
  //     emit(QuotationConvertedToSale(saleOrder));
  //   } catch (e) {
  //     emit(QuotationsError(e.toString()));
  //   }
  // }
}