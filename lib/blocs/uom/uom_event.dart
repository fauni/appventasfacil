import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:equatable/equatable.dart';

abstract class UomEvent extends Equatable {
  const UomEvent();

  @override
  List<Object> get props => [];
}

class UomLoadRequested extends UomEvent {
  final String itemCode;

  const UomLoadRequested(this.itemCode);

  @override
  List<Object> get props => [itemCode];
}

class UomSelected extends UomEvent {
  final UnitOfMeasure unitOfMeasure;

  const UomSelected(this.unitOfMeasure);

  @override
  List<Object> get props => [unitOfMeasure];
}

class UomCleared extends UomEvent {
  final String? itemCode;

  const UomCleared({this.itemCode});

  @override
  List<Object> get props => [itemCode ?? ''];
}