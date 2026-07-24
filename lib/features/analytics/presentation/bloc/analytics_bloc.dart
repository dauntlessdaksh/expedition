import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/analytics_repository.dart';
import '../../domain/models/analytics_data.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

/// Loads and refreshes analytics metrics for the analytics screen.
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  AnalyticsBloc({required AnalyticsRepository repository})
      : _repository = repository,
        super(const AnalyticsState()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<RefreshAnalytics>(_onRefreshAnalytics);
  }

  final AnalyticsRepository _repository;

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _loadAnalytics(emit);
  }

  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    await _loadAnalytics(emit, isRefresh: true);
  }

  Future<void> _loadAnalytics(
    Emitter<AnalyticsState> emit, {
    bool isRefresh = false,
  }) async {
    if (!isRefresh) {
      emit(state.copyWith(status: AnalyticsStatus.loading));
    }

    try {
      final data = await _repository.getAnalyticsData();
      emit(state.copyWith(
        status: data.isEmpty ? AnalyticsStatus.empty : AnalyticsStatus.loaded,
        data: data,
      ));
    } on Exception {
      emit(state.copyWith(status: AnalyticsStatus.failure));
    }
  }
}
