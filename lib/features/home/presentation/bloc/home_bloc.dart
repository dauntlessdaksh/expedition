import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/home_repository.dart';
import '../../domain/models/home_dashboard_data.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Loads and exposes home dashboard data to the UI.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  final HomeRepository _repository;

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<HomeState> emit,
  ) async {
    await _loadDashboard(emit);
  }

  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<HomeState> emit,
  ) async {
    await _loadDashboard(emit, isRefresh: true);
  }

  Future<void> _loadDashboard(
    Emitter<HomeState> emit, {
    bool isRefresh = false,
  }) async {
    if (!isRefresh) {
      emit(state.copyWith(status: HomeStatus.loading));
    }

    try {
      final data = await _repository.getDashboardData();
      emit(state.copyWith(
        status: HomeStatus.loaded,
        data: data,
      ));
    } on Exception {
      emit(state.copyWith(status: HomeStatus.failure));
    }
  }
}
