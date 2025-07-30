import 'package:appventas/models/login_request.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable{
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final LoginRequest loginRequest;

  const AuthLoginRequested(this.loginRequest);

  @override
  List<Object> get props => [loginRequest];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthStatusChecked extends AuthEvent {}