part of 'analytics_bloc.dart';

sealed class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadAnalytics extends AnalyticsEvent {
  const LoadAnalytics();
}

final class RefreshAnalytics extends AnalyticsEvent {
  const RefreshAnalytics();
}
