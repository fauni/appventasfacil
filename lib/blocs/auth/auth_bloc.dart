import 'package:appventas/services/auth_service.dart';
import 'package:appventas/services/storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
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

      emit(AuthAuthenticated(user: loginResponse.user, token: loginResponse.token));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await StorageService.clearAll();
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
        final token = await StorageService.getToken();
        if (user != null && token != null) {
          emit(AuthAuthenticated(user: user, token: token));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}