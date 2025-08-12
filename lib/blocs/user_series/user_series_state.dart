import 'package:appventas/models/user_serie.dart';
import 'package:equatable/equatable.dart';

abstract class UserSeriesState extends Equatable {
  const UserSeriesState();

  @override
  List<Object?> get props => [];
}

class UserSeriesInitial extends UserSeriesState {}

class UserSeriesLoading extends UserSeriesState {}

class UserSeriesLoaded extends UserSeriesState {
  final List<UserSerie> userSeries;
  final UserSerie? selectedSerie;

  const UserSeriesLoaded({
    required this.userSeries,
    this.selectedSerie,
  });

  @override
  List<Object?> get props => [userSeries, selectedSerie];

  UserSeriesLoaded copyWith({
    List<UserSerie>? userSeries,
    UserSerie? selectedSerie,
  }) {
    return UserSeriesLoaded(
      userSeries: userSeries ?? this.userSeries,
      selectedSerie: selectedSerie ?? this.selectedSerie,
    );
  }
}

class UserSeriesEmpty extends UserSeriesState {
  final String message;

  const UserSeriesEmpty(this.message);

  @override
  List<Object> get props => [message];
}

class UserSeriesError extends UserSeriesState {
  final String message;

  const UserSeriesError(this.message);

  @override
  List<Object> get props => [message];
}

class UserSeriesAssigned extends UserSeriesState {
  final UserSerie assignedSerie;

  const UserSeriesAssigned(this.assignedSerie);

  @override
  List<Object> get props => [assignedSerie];
}