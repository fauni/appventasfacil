// lib/blocs/sales_order/sales_order_state.dart
import 'package:appventas/models/sales_order/sales_order.dart';
import 'package:appventas/models/sales_order/sales_order_response.dart';
import 'package:equatable/equatable.dart';

abstract class SalesOrderState extends Equatable {
  const SalesOrderState();

  @override
  List<Object?> get props => [];
}

class SalesOrderInitial extends SalesOrderState {}

class SalesOrderLoading extends SalesOrderState {}

class SalesOrderLoaded extends SalesOrderState {
  final List<SalesOrder> salesOrders;

  const SalesOrderLoaded(this.salesOrders);

  @override
  List<Object?> get props => [salesOrders];
}

class SalesOrderCreated extends SalesOrderState {
  final SalesOrderResponse response;

  const SalesOrderCreated(this.response);

  @override
  List<Object?> get props => [response];
}

class SalesOrderDetailLoaded extends SalesOrderState {
  final SalesOrder salesOrder;

  const SalesOrderDetailLoaded(this.salesOrder);

  @override
  List<Object?> get props => [salesOrder];
}

class SalesOrderError extends SalesOrderState {
  final String message;

  const SalesOrderError(this.message);

  @override
  List<Object?> get props => [message];
}