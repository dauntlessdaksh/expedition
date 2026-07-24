part of 'home_bloc.dart';

enum HomeStatus {
  initial,
  loading,
  loaded,
  failure,
}

final class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.data,
  });

  final HomeStatus status;
  final HomeDashboardData? data;

  HomeState copyWith({
    HomeStatus? status,
    HomeDashboardData? data,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [status, data];
}
