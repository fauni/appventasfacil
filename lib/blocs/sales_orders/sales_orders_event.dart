import 'package:appventas/models/sales_order/sales_order_dto.dart';
import 'package:appventas/models/sales_order/sales_order_search_request.dart';
import 'package:equatable/equatable.dart';

abstract class SalesOrdersEvent extends Equatable {
  const SalesOrdersEvent();

  @override
  List<Object?> get props => [];
}

class SalesOrdersLoadRequested extends SalesOrdersEvent {}

class SalesOrdersSearchRequested extends SalesOrdersEvent {
  final SalesOrderSearchRequest request;

  const SalesOrdersSearchRequested(this.request);

  @override
  List<Object> get props => [request];
}

class SalesOrderDetailRequested extends SalesOrdersEvent {
  final int docEntry;

  const SalesOrderDetailRequested(this.docEntry);

  @override
  List<Object> get props => [docEntry];
}

class SalesOrdersByCustomerRequested extends SalesOrdersEvent {
  final String cardCode;
  final int pageSize;
  final int pageNumber;

  const SalesOrdersByCustomerRequested(
    this.cardCode, {
    this.pageSize = 20,
    this.pageNumber = 1,
  });

  @override
  List<Object> get props => [cardCode, pageSize, pageNumber];
}

class SalesOrdersBySalesPersonRequested extends SalesOrdersEvent {
  final int slpCode;
  final int pageSize;
  final int pageNumber;

  const SalesOrdersBySalesPersonRequested(
    this.slpCode, {
    this.pageSize = 20,
    this.pageNumber = 1,
  });

  @override
  List<Object> get props => [slpCode, pageSize, pageNumber];
}

class SalesOrderCreateRequested extends SalesOrdersEvent {
  final SalesOrderDto orderDto;

  const SalesOrderCreateRequested(this.orderDto);

  @override
  List<Object> get props => [orderDto];
}

class SalesOrdersRefreshRequested extends SalesOrdersEvent {}

class SalesOrdersLoadMoreRequested extends SalesOrdersEvent {
  final SalesOrderSearchRequest request;

  const SalesOrdersLoadMoreRequested(this.request);

  @override
  List<Object> get props => [request];
}

class SalesOrdersFilterChanged extends SalesOrdersEvent {
  final SalesOrderSearchRequest request;

  const SalesOrdersFilterChanged(this.request);

  @override
  List<Object> get props => [request];
}