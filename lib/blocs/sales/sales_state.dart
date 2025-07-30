import 'package:equatable/equatable.dart';

abstract class SalesState extends Equatable {
  const SalesState();

  @override
  List<Object> get props => [];
}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final List<dynamic> salesOrders;

  const SalesLoaded(this.salesOrders);

  @override
  List<Object> get props => [salesOrders];
}

class SaleCreated extends SalesState {
  final dynamic saleOrder;

  const SaleCreated(this.saleOrder);

  @override
  List<Object> get props => [saleOrder];
}

class SalesError extends SalesState {
  final String message;

  const SalesError(this.message);

  @override
  List<Object> get props => [message];
}
