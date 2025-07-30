import 'package:appventas/models/sales_quotation_dto.dart';
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