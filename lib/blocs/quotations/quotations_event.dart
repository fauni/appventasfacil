import 'package:appventas/models/quotation/sales_quotation_dto.dart';
import 'package:equatable/equatable.dart';

abstract class QuotationsEvent extends Equatable {
  const QuotationsEvent();

  @override
  List<Object> get props => [];
}

class QuotationsLoadRequested extends QuotationsEvent {}

class QuotationCreateRequested extends QuotationsEvent {
  final SalesQuotationDto quotationDto;

  const QuotationCreateRequested(this.quotationDto);

  @override
  List<Object> get props => [quotationDto];
}

class QuotationConvertToSaleRequested extends QuotationsEvent {
  final int docEntry;

  const QuotationConvertToSaleRequested(this.docEntry);

  @override
  List<Object> get props => [docEntry];
}

// NUEVOS EVENTOS PARA PDF
class QuotationPdfPreviewRequested extends QuotationsEvent {
  final int docEntry;
  final String docNum;

  const QuotationPdfPreviewRequested(this.docEntry, this.docNum);

  @override
  List<Object> get props => [docEntry, docNum];
}

class QuotationPdfShareRequested extends QuotationsEvent {
  final int docEntry;
  final String docNum;

  const QuotationPdfShareRequested(this.docEntry, this.docNum);

  @override
  List<Object> get props => [docEntry, docNum];
}

class QuotationPdfPrintRequested extends QuotationsEvent {
  final int docEntry;
  final String docNum;

  const QuotationPdfPrintRequested(this.docEntry, this.docNum);

  @override
  List<Object> get props => [docEntry, docNum];
}