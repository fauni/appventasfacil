import 'package:equatable/equatable.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object> get props => [];
}

class SalesLoadRequested extends SalesEvent {}

class SaleCreateFromQuotationRequested extends SalesEvent {
  final int quotationDocEntry;

  const SaleCreateFromQuotationRequested(this.quotationDocEntry);

  @override
  List<Object> get props => [quotationDocEntry];
}