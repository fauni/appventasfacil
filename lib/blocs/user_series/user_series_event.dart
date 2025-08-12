import 'package:appventas/models/user_serie.dart';
import 'package:equatable/equatable.dart';

abstract class UserSeriesEvent extends Equatable {
  const UserSeriesEvent();

  @override
  List<Object> get props => [];
}

class UserSeriesLoadRequested extends UserSeriesEvent {
  final int userId;

  const UserSeriesLoadRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

class UserSeriesAssignRequested extends UserSeriesEvent {
  final int userId;
  final String seriesId;

  const UserSeriesAssignRequested({
    required this.userId,
    required this.seriesId,
  });

  @override
  List<Object> get props => [userId, seriesId];
}

class UserSeriesSelected extends UserSeriesEvent {
  final UserSerie userSerie;

  const UserSeriesSelected(this.userSerie);

  @override
  List<Object> get props => [userSerie];
}

class UserSeriesCleared extends UserSeriesEvent {}