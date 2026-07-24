import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/dummy_home_repository.dart';
import '../../domain/models/home_dashboard_data.dart';

part 'home_event.dart';
part 'home_state.dart';

/// Loads and exposes home dashboard data to the UI.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required DummyHomeRepository repository})
      : _repository = repository,
        super(const HomeState()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
  }

  final DummyHomeRepository _repository;

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    await _loadDashboard(emit);
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
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
