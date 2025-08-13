import 'package:appventas/models/item/tfe_unit_of_measure.dart';
import 'package:equatable/equatable.dart';

abstract class TfeUomEvent extends Equatable {
  const TfeUomEvent();

  @override
  List<Object> get props => [];
}

class TfeUomLoadRequested extends TfeUomEvent {}

class TfeUomSelected extends TfeUomEvent {
  final TfeUnitOfMeasure tfeUnitOfMeasure;

  const TfeUomSelected(this.tfeUnitOfMeasure);

  @override
  List<Object> get props => [tfeUnitOfMeasure];
}

class TfeUomCleared extends TfeUomEvent {}
