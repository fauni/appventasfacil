import 'package:appventas/models/item/tfe_unit_of_measure.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/tfe_unit_of_measure_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'tfe_uom_event.dart';
import 'tfe_uom_state.dart';

class TfeUomBloc extends Bloc<TfeUomEvent, TfeUomState> {
  List<TfeUnitOfMeasure> _tfeUnitsCache = [];
  TfeUnitOfMeasure? _selectedTfeUom;

  TfeUomBloc() : super(TfeUomInitial()) {
    on<TfeUomLoadRequested>(_onTfeUomLoadRequested);
    on<TfeUomSelected>(_onTfeUomSelected);
    on<TfeUomCleared>(_onTfeUomCleared);
  }

  Future<void> _onTfeUomLoadRequested(
    TfeUomLoadRequested event,
    Emitter<TfeUomState> emit,
  ) async {
    try {
      emit(TfeUomLoading());

      // Verificar cache primero
      if (_tfeUnitsCache.isNotEmpty) {
        emit(TfeUomLoaded(
          tfeUnitsOfMeasure: _tfeUnitsCache,
          selectedTfeUom: _selectedTfeUom,
        ));
        return;
      }

      final tfeUnitsOfMeasure = await TfeUnitOfMeasureService.getTfeUnitsOfMeasure();
      
      // Guardar en cache
      _tfeUnitsCache = tfeUnitsOfMeasure;
      
      // Seleccionar TFE UoM por defecto si no hay una seleccionada
      if (_selectedTfeUom == null && tfeUnitsOfMeasure.isNotEmpty) {
        // Buscar '80' como código por defecto
        try {
          _selectedTfeUom = tfeUnitsOfMeasure.firstWhere((tfeUom) => tfeUom.code == '80');
        } catch (e) {
          _selectedTfeUom = tfeUnitsOfMeasure.first;
        }
      }

      emit(TfeUomLoaded(
        tfeUnitsOfMeasure: tfeUnitsOfMeasure,
        selectedTfeUom: _selectedTfeUom,
      ));
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en TfeUomBloc');
    } catch (e) {
      emit(TfeUomError('Error al cargar unidades de medida TFE: ${e.toString()}'));
    }
  }

  void _onTfeUomSelected(
    TfeUomSelected event,
    Emitter<TfeUomState> emit,
  ) {
    final currentState = state;
    if (currentState is TfeUomLoaded) {
      _selectedTfeUom = event.tfeUnitOfMeasure;
      
      emit(currentState.copyWith(
        selectedTfeUom: event.tfeUnitOfMeasure,
        updateSelectedTfeUom: true,
      ));
    }
  }

  void _onTfeUomCleared(
    TfeUomCleared event,
    Emitter<TfeUomState> emit,
  ) {
    _selectedTfeUom = null;
    _tfeUnitsCache.clear();
    emit(TfeUomInitial());
  }

  // Métodos de utilidad
  TfeUnitOfMeasure? get selectedTfeUom => _selectedTfeUom;
  List<TfeUnitOfMeasure> get tfeUnitsCache => _tfeUnitsCache;
}