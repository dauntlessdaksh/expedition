part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

final class LoadDashboard extends HomeEvent {
  const LoadDashboard();
}

final class RefreshDashboard extends HomeEvent {
  const RefreshDashboard();
}
