import 'package:appventas/models/user_serie.dart';
import 'package:appventas/services/user_serie_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:appventas/services/http_client.dart';
import 'user_series_event.dart';
import 'user_series_state.dart';

class UserSeriesBloc extends Bloc<UserSeriesEvent, UserSeriesState> {
  UserSerie? _selectedSerie;

  UserSerie? get selectedSerie => _selectedSerie;

  UserSeriesBloc() : super(UserSeriesInitial()) {
    on<UserSeriesLoadRequested>(_onLoadRequested);
    on<UserSeriesAssignRequested>(_onAssignRequested);
    on<UserSeriesSelected>(_onSelected);
    on<UserSeriesCleared>(_onCleared);
  }

  Future<void> _onLoadRequested(
    UserSeriesLoadRequested event,
    Emitter<UserSeriesState> emit,
  ) async {
    emit(UserSeriesLoading());
    
    try {
      final userSeries = await UserSeriesService.getUserSeries(event.userId);
      
      if (userSeries.isEmpty) {
        _selectedSerie = null;
        emit(const UserSeriesEmpty('No tienes series asignadas'));
      } else {
        // Seleccionar automáticamente la primera serie si no hay ninguna seleccionada
        // o si la serie seleccionada no está en la lista actual
        UserSerie selectedSerie;
        final currentSelectedId = _selectedSerie?.id;
        
        if (currentSelectedId != null) {
          // Buscar la serie previamente seleccionada en la nueva lista con verificación null-safe
          UserSerie? foundSerie;
          for (final serie in userSeries) {
            if (serie.id == currentSelectedId) {
              foundSerie = serie;
              break;
            }
          }
          selectedSerie = foundSerie ?? userSeries.first;
        } else {
          selectedSerie = userSeries.first;
        }
        
        _selectedSerie = selectedSerie;
        
        emit(UserSeriesLoaded(
          userSeries: userSeries,
          selectedSerie: selectedSerie,
        ));
      }
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en UserSeriesBloc');
      _selectedSerie = null;
      // Manejar sesión expirada según el patrón de la app
    } catch (e) {
      _selectedSerie = null;
      emit(UserSeriesError('Error al cargar series: ${e.toString()}'));
    }
  }

  Future<void> _onAssignRequested(
    UserSeriesAssignRequested event,
    Emitter<UserSeriesState> emit,
  ) async {
    try {
      final assignedSerie = await UserSeriesService.assignSeries(
        userId: event.userId,
        seriesId: event.seriesId,
      );

      emit(UserSeriesAssigned(assignedSerie));
      
      // Recargar las series después de asignar una nueva
      add(UserSeriesLoadRequested(event.userId));
    } on UnauthorizedException {
      print('🔓 Sesión expirada detectada en UserSeriesBloc');
    } catch (e) {
      emit(UserSeriesError('Error al asignar serie: ${e.toString()}'));
    }
  }

  void _onSelected(
    UserSeriesSelected event,
    Emitter<UserSeriesState> emit,
  ) {
    _selectedSerie = event.userSerie;
    
    if (state is UserSeriesLoaded) {
      final currentState = state as UserSeriesLoaded;
      emit(currentState.copyWith(selectedSerie: event.userSerie));
    }
  }

  void _onCleared(
    UserSeriesCleared event,
    Emitter<UserSeriesState> emit,
  ) {
    _selectedSerie = null;
    emit(UserSeriesInitial());
  }
}
