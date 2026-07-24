part of 'analytics_bloc.dart';

enum AnalyticsStatus {
  initial,
  loading,
  loaded,
  empty,
  failure,
}

final class AnalyticsState extends Equatable {
  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.data,
  });

  final AnalyticsStatus status;
  final AnalyticsData? data;

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsData? data,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [status, data];
}
