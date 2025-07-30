import 'package:equatable/equatable.dart';
import '../../models/sales_quotation.dart';

abstract class QuotationsState extends Equatable {
  const QuotationsState();

  @override
  List<Object> get props => [];
}

class QuotationsInitial extends QuotationsState {}

class QuotationsLoading extends QuotationsState {}

class QuotationsLoaded extends QuotationsState {
  final List<SalesQuotation> quotations;

  const QuotationsLoaded(this.quotations);

  @override
  List<Object> get props => [quotations];
}

class QuotationCreated extends QuotationsState {
  final String result;

  const QuotationCreated(this.result);

  @override
  List<Object> get props => [result];
}

// Revisar este estado, ya que no se especifica qué tipo de orden de venta se crea
class QuotationConvertedToSale extends QuotationsState {
  final dynamic saleOrder;

  const QuotationConvertedToSale(this.saleOrder);

  @override
  List<Object> get props => [saleOrder];
}

class QuotationsError extends QuotationsState {
  final String message;

  const QuotationsError(this.message);

  @override
  List<Object> get props => [message];
}