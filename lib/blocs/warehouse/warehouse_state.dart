// lib/blocs/warehouse/warehouse_state.dart
import 'package:appventas/models/warehouse/warehouse.dart';
import 'package:equatable/equatable.dart';

abstract class WarehouseState extends Equatable {
  const WarehouseState();

  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {
  const WarehouseInitial();
}

class WarehouseLoading extends WarehouseState {
  const WarehouseLoading();
}

class WarehouseLoadingMore extends WarehouseState {
  final WarehouseSearchResponse currentData;

  const WarehouseLoadingMore(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

class WarehousesLoaded extends WarehouseState {
  final List<Warehouse> warehouses;

  const WarehousesLoaded(this.warehouses);

  @override
  List<Object?> get props => [warehouses];
}

class WarehousesSearchLoaded extends WarehouseState {
  final WarehouseSearchResponse response;
  final WarehouseSearchRequest request;

  const WarehousesSearchLoaded(this.response, this.request);

  @override
  List<Object?> get props => [response, request];
}

class WarehouseDetailLoaded extends WarehouseState {
  final Warehouse warehouse;

  const WarehouseDetailLoaded(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

class WarehouseSelected extends WarehouseState {
  final Warehouse warehouse;

  const WarehouseSelected(this.warehouse);

  @override
  List<Object?> get props => [warehouse];
}

class WarehouseError extends WarehouseState {
  final String message;

  const WarehouseError(this.message);

  @override
  List<Object?> get props => [message];
}

class WarehouseEmpty extends WarehouseState {
  final String message;

  const WarehouseEmpty(this.message);

  @override
  List<Object?> get props => [message];
}