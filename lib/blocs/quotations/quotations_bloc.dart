import 'package:appventas/services/pdf_report_service.dart';
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
    // NUEVOS HANDLERS PARA PDF
    on<QuotationPdfPreviewRequested>(_onPdfPreviewRequested);
    on<QuotationPdfShareRequested>(_onPdfShareRequested);
    on<QuotationPdfPrintRequested>(_onPdfPrintRequested);
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

  // NUEVOS MÉTODOS PARA PDF
  Future<void> _onPdfPreviewRequested(QuotationPdfPreviewRequested event, Emitter<QuotationsState> emit) async {
    emit(const QuotationPdfLoading('preview', 'Descargando PDF desde servidor...'));
    try {
      await PdfReportService.previewQuotationPdf(event.docEntry, event.docNum);
      emit(QuotationPdfPreviewSuccess());
    } catch (e) {
      emit(QuotationPdfError('preview', 'Error al generar vista previa: ${e.toString()}'));
    }
  }

  Future<void> _onPdfShareRequested(QuotationPdfShareRequested event, Emitter<QuotationsState> emit) async {
    emit(const QuotationPdfLoading('share', 'Descargando PDF desde servidor...'));
    try {
      await PdfReportService.shareQuotationPdf(event.docEntry, event.docNum);
      emit(const QuotationPdfShareSuccess('PDF descargado y listo para compartir'));
    } catch (e) {
      emit(QuotationPdfError('share', 'Error al descargar PDF: ${e.toString()}'));
    }
  }

  Future<void> _onPdfPrintRequested(QuotationPdfPrintRequested event, Emitter<QuotationsState> emit) async {
    emit(const QuotationPdfLoading('print', 'Descargando PDF desde servidor...'));
    try {
      await PdfReportService.printQuotationPdf(event.docEntry, event.docNum);
      emit(QuotationPdfPrintSuccess());
    } catch (e) {
      emit(QuotationPdfError('print', 'Error al imprimir: ${e.toString()}'));
    }
  }
}