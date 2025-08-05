import 'package:appventas/models/item/unit_of_measure.dart';
import 'package:appventas/services/http_client.dart';
import 'package:appventas/services/unit_of_measure_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'uom_event.dart';
import 'uom_state.dart';

class UomBloc extends Bloc<UomEvent, UomState> {
  // Mapa para mantener UoMs por item
  final Map<String, List<UnitOfMeasure>> _uomCache = {};
  final Map<String, UnitOfMeasure?> _selectedUoms = {};

  UomBloc() : super(UomInitial()) {
    on<UomLoadRequested>(_onUomLoadRequested);
    on<UomSelected>(_onUomSelected);
    on<UomCleared>(_onUomCleared);
  }

  Future<void> _onUomLoadRequested(
    UomLoadRequested event,
    Emitter<UomState> emit,
  ) async {
    try {
      emit(UomLoading(event.itemCode));

      // Verificar cache primero
      if (_uomCache.containsKey(event.itemCode)) {
        emit(UomLoaded(
          itemCode: event.itemCode,
          unitOfMeasures: _uomCache[event.itemCode]!,
          selectedUom: _selectedUoms[event.itemCode],
        ));
        return;
      }

      final unitOfMeasures = await UnitOfMeasureService.getUnitOfMeasuresByItem(event.itemCode);
      
      // Guardar en cache
      _uomCache[event.itemCode] = unitOfMeasures;
      
      // Seleccionar UoM por defecto si no hay una seleccionada
      UnitOfMeasure? selectedUom = _selectedUoms[event.itemCode];
      if (selectedUom == null && unitOfMeasures.isNotEmpty) {
        // Buscar la unidad por defecto o usar la primera
        selectedUom = unitOfMeasures.firstWhere(
          (uom) => uom.isDefault,
          orElse: () => unitOfMeasures.first,
        );
        _selectedUoms[event.itemCode] = selectedUom;
      }

      emit(UomLoaded(
        itemCode: event.itemCode,
        unitOfMeasures: unitOfMeasures,
        selectedUom: selectedUom,
      ));
    } on UnauthorizedException {
      // HttpClient ya manejó la redirección
      print('🔓 Sesión expirada detectada en UomBloc');
    } catch (e) {
      emit(UomError('Error al cargar unidades de medida: ${e.toString()}', itemCode: event.itemCode));
    }
  }

  void _onUomSelected(
    UomSelected event,
    Emitter<UomState> emit,
  ) {
    final currentState = state;
    if (currentState is UomLoaded && currentState.itemCode == event.unitOfMeasure.itemCode) {
      _selectedUoms[event.unitOfMeasure.itemCode] = event.unitOfMeasure;
      
      // FIX: Usar el flag para actualizar solo selectedUom
      emit(currentState.copyWith(
        selectedUom: event.unitOfMeasure,
        updateSelectedUom: true, // Indicar que sí queremos actualizar
      ));
    }
  }

  void _onUomCleared(
    UomCleared event,
    Emitter<UomState> emit,
  ) {
    if (event.itemCode != null) {
      // Limpiar para un item específico
      _selectedUoms.remove(event.itemCode);
      _uomCache.remove(event.itemCode);
    } else {
      // Limpiar todo
      _selectedUoms.clear();
      _uomCache.clear();
    }
    
    emit(UomInitial());
  }

  // Métodos de utilidad
  UnitOfMeasure? getSelectedUomForItem(String itemCode) {
    return _selectedUoms[itemCode];
  }

  List<UnitOfMeasure>? getUomsForItem(String itemCode) {
    return _uomCache[itemCode];
  }

  bool hasUomsForItem(String itemCode) {
    return _uomCache.containsKey(itemCode) && _uomCache[itemCode]!.isNotEmpty;
  }
}