import 'package:appventas/models/item/tfe_unit_of_measure.dart';
import 'package:equatable/equatable.dart';

abstract class TfeUomState extends Equatable {
  const TfeUomState();

  @override
  List<Object?> get props => [];
}

class TfeUomInitial extends TfeUomState {}

class TfeUomLoading extends TfeUomState {}

class TfeUomLoaded extends TfeUomState {
  final List<TfeUnitOfMeasure> tfeUnitsOfMeasure;
  final TfeUnitOfMeasure? selectedTfeUom;

  const TfeUomLoaded({
    required this.tfeUnitsOfMeasure,
    this.selectedTfeUom,
  });

  TfeUomLoaded copyWith({
    List<TfeUnitOfMeasure>? tfeUnitsOfMeasure,
    TfeUnitOfMeasure? selectedTfeUom,
    bool updateSelectedTfeUom = false,
  }) {
    return TfeUomLoaded(
      tfeUnitsOfMeasure: tfeUnitsOfMeasure ?? this.tfeUnitsOfMeasure,
      selectedTfeUom: updateSelectedTfeUom ? selectedTfeUom : this.selectedTfeUom,
    );
  }

  TfeUnitOfMeasure? get defaultTfeUom {
    // Buscar '80' como código por defecto, o usar el primero disponible
    try {
      return tfeUnitsOfMeasure.firstWhere((tfeUom) => tfeUom.code == '80');
    } catch (e) {
      return tfeUnitsOfMeasure.isNotEmpty ? tfeUnitsOfMeasure.first : null;
    }
  }

  @override
  List<Object?> get props => [tfeUnitsOfMeasure, selectedTfeUom];
}

class TfeUomError extends TfeUomState {
  final String message;

  const TfeUomError(this.message);

  @override
  List<Object?> get props => [message];
}
