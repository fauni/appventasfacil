import 'package:appventas/models/sales_order/sales_order.dart';
import 'package:appventas/models/sales_order/sales_order_search_request.dart';
import 'package:equatable/equatable.dart';

abstract class SalesOrdersState extends Equatable {
  const SalesOrdersState();

  @override
  List<Object?> get props => [];
}

class SalesOrdersInitial extends SalesOrdersState {}

class SalesOrdersLoading extends SalesOrdersState {}

class SalesOrdersLoaded extends SalesOrdersState {
  final SalesOrderSearchResponse response;
  final SalesOrderSearchRequest currentRequest;

  const SalesOrdersLoaded(this.response, this.currentRequest);

  @override
  List<Object> get props => [response, currentRequest];
}

class SalesOrdersLoadingMore extends SalesOrdersState {
  final SalesOrderSearchResponse currentResponse;
  final SalesOrderSearchRequest currentRequest;

  const SalesOrdersLoadingMore(this.currentResponse, this.currentRequest);

  @override
  List<Object> get props => [currentResponse, currentRequest];
}

class SalesOrderDetailLoading extends SalesOrdersState {}

class SalesOrderDetailLoaded extends SalesOrdersState {
  final SalesOrder order;

  const SalesOrderDetailLoaded(this.order);

  @override
  List<Object> get props => [order];
}

class SalesOrdersByCustomerLoaded extends SalesOrdersState {
  final List<SalesOrder> orders;
  final String cardCode;

  const SalesOrdersByCustomerLoaded(this.orders, this.cardCode);

  @override
  List<Object> get props => [orders, cardCode];
}

class SalesOrdersBySalesPersonLoaded extends SalesOrdersState {
  final List<SalesOrder> orders;
  final int slpCode;

  const SalesOrdersBySalesPersonLoaded(this.orders, this.slpCode);

  @override
  List<Object> get props => [orders, slpCode];
}

class SalesOrderCreated extends SalesOrdersState {
  final String result;

  const SalesOrderCreated(this.result);

  @override
  List<Object> get props => [result];
}

class SalesOrdersError extends SalesOrdersState {
  final String message;

  const SalesOrdersError(this.message);

  @override
  List<Object> get props => [message];
}

class SalesOrdersEmpty extends SalesOrdersState {
  final String message;

  const SalesOrdersEmpty(this.message);

  @override
  List<Object> get props => [message];
}
