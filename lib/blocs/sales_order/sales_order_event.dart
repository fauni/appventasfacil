// lib/blocs/sales_order/sales_order_event.dart
import 'package:appventas/models/sales_order/sales_order_dto.dart';
import 'package:equatable/equatable.dart';

abstract class SalesOrderEvent extends Equatable {
  const SalesOrderEvent();

  @override
  List<Object?> get props => [];
}

class SalesOrderLoadRequested extends SalesOrderEvent {}

class SalesOrderCreateRequested extends SalesOrderEvent {
  final SalesOrderDto salesOrderDto;

  const SalesOrderCreateRequested(this.salesOrderDto);

  @override
  List<Object?> get props => [salesOrderDto];
}

class SalesOrderByIdRequested extends SalesOrderEvent {
  final int docEntry;

  const SalesOrderByIdRequested(this.docEntry);

  @override
  List<Object?> get props => [docEntry];
}

class SalesOrderReset extends SalesOrderEvent {}