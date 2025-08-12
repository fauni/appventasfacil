// lib/blocs/warehouse/warehouse_event.dart
import 'package:appventas/models/warehouse/warehouse.dart';
import 'package:equatable/equatable.dart';

abstract class WarehouseEvent extends Equatable {
  const WarehouseEvent();

  @override
  List<Object?> get props => [];
}

class WarehousesLoadRequested extends WarehouseEvent {
  const WarehousesLoadRequested();
}

class WarehousesSearchRequested extends WarehouseEvent {
  final WarehouseSearchRequest request;

  const WarehousesSearchRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class WarehousesSearchTermChanged extends WarehouseEvent {
  final String searchTerm;

  const WarehousesSearchTermChanged(this.searchTerm);

  @override
  List<Object?> get props => [searchTerm];
}

class WarehousesLoadMoreRequested extends WarehouseEvent {
  const WarehousesLoadMoreRequested();
}

class WarehousesRefreshRequested extends WarehouseEvent {
  const WarehousesRefreshRequested();
}

class WarehouseByCodeRequested extends WarehouseEvent {
  final String whsCode;

  const WarehouseByCodeRequested(this.whsCode);

  @override
  List<Object?> get props => [whsCode];
}

class WarehouseSelectedEvent extends WarehouseEvent {
  final Warehouse warehouse;

  const WarehouseSelectedEvent(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

class WarehouseSelectionCleared extends WarehouseEvent {
  const WarehouseSelectionCleared();
}