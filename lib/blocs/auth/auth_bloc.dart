import 'package:appventas/services/auth_service.dart';
import 'package:appventas/services/current_user_service.dart';
import 'package:appventas/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final CurrentUserService _currentUserService = CurrentUserService();

  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onStatusChecked);
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final loginResponse = await AuthService.login(event.loginRequest);

      // Save token and user data
      await StorageService.saveToken(loginResponse.token);
      await StorageService.saveUser(loginResponse.user);

      await StorageService.saveUser(loginResponse.user);
      if (loginResponse.salesPerson != null) {
        await StorageService.saveSalesPerson(loginResponse.salesPerson!);
      }

      // Actualizar CurrentUserService con el usuario logueado
      _currentUserService.setCurrentUser(loginResponse.user, loginResponse.salesPerson);

      emit(AuthAuthenticated(user: loginResponse.user, token: loginResponse.token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await StorageService.clearAll();

      // Limpiar CurrentUserService
      _currentUserService.clearCurrentUser();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onStatusChecked(AuthStatusChecked event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        final user = await StorageService.getUser();
        final salesPerson = await StorageService.getSalesPerson();
        final token = await StorageService.getToken();
        if (user != null && token != null) {
          // Actualizar CurrentUserService con el usuario cargado
          _currentUserService.setCurrentUser(user);

          emit(AuthAuthenticated(user: user, token: token));
        } else {
          _currentUserService.clearCurrentUser();
          emit(AuthUnauthenticated());
        }
      } else {
        _currentUserService.clearCurrentUser();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      _currentUserService.clearCurrentUser();
      emit(AuthUnauthenticated());
    }
  }
}