import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:equatable/equatable.dart';

abstract class UomState extends Equatable {
  const UomState();

  @override
  List<Object?> get props => [];
}

class UomInitial extends UomState {}

class UomLoading extends UomState {
  final String itemCode;

  const UomLoading(this.itemCode);

  @override
  List<Object> get props => [itemCode];
}

class UomLoaded extends UomState {
  final String itemCode;
  final List<UnitOfMeasure> unitOfMeasures;
  final UnitOfMeasure? selectedUom;

  const UomLoaded({
    required this.itemCode,
    required this.unitOfMeasures,
    this.selectedUom,
  });

  // FIX: Corregir el copyWith para preservar selectedUom
  UomLoaded copyWith({
    String? itemCode,
    List<UnitOfMeasure>? unitOfMeasures,
    UnitOfMeasure? selectedUom,
    bool updateSelectedUom = false, // Flag para controlar actualización
  }) {
    return UomLoaded(
      itemCode: itemCode ?? this.itemCode,
      unitOfMeasures: unitOfMeasures ?? this.unitOfMeasures,
      selectedUom: updateSelectedUom ? selectedUom : this.selectedUom,
    );
  }

  UnitOfMeasure? get defaultUom {
    try {
      return unitOfMeasures.firstWhere((uom) => uom.isDefault);
    } catch (e) {
      return unitOfMeasures.isNotEmpty ? unitOfMeasures.first : null;
    }
  }

  @override
  List<Object?> get props => [itemCode, unitOfMeasures, selectedUom];
}

class UomError extends UomState {
  final String message;
  final String? itemCode;

  const UomError(this.message, {this.itemCode});

  @override
  List<Object?> get props => [message, itemCode];
}