import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/navigation/main_navigation.dart';
import '../../../../core/navigation/main_tab.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/premium_empty_state.dart';
import '../../../../core/widgets/skeleton/skeleton_loaders.dart';
import '../../domain/models/history_filter.dart';
import '../../domain/models/history_sort.dart';
import '../bloc/history_bloc.dart';
import '../widgets/history_search_bar.dart';
import '../widgets/workout_history_card.dart';

/// Lists saved workouts with search, filter, and sort controls.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistoryBloc, HistoryState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.deletedWorkoutId != current.deletedWorkoutId,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<HistoryBloc>().add(const ClearHistoryMessage());
        }

        if (state.deletedWorkoutId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Workout deleted')),
          );
          context.read<HistoryBloc>().add(const ClearHistoryMessage());
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColorPalette.darkBackground,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: PremiumGradients.darkBackground,
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppSpacing.sm),
                        const Expanded(
                          child: Text(
                            'Workout History',
                            style: TextStyle(
                              color: AppColorPalette.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _SortButton(
                          selectedSort: state.sort,
                          onSortSelected: (sort) => context
                              .read<HistoryBloc>()
                              .add(SortWorkout(sort)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        HistorySearchBar(
                          query: state.searchQuery,
                          onChanged: (query) => context
                              .read<HistoryBloc>()
                              .add(SearchWorkout(query)),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        HistoryFilterBar(
                          selectedFilter: state.filter,
                          onFilterSelected: (filter) => context
                              .read<HistoryBloc>()
                              .add(FilterWorkout(filter)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      child: KeyedSubtree(
                        key: ValueKey(_contentKey(state)),
                        child: _HistoryBody(state: state),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _contentKey(HistoryState state) {
    return '${state.status}_${state.visibleWorkouts.length}_${state.searchQuery}_${state.filter}';
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.state});

  final HistoryState state;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      HistoryStatus.initial ||
      HistoryStatus.loading ||
      HistoryStatus.deleting =>
        SkeletonLoaders.history(),
      HistoryStatus.failure => AppErrorView(
          failure: FailureMapper.from(
            StateError(state.errorMessage ?? 'Unable to load workout history.'),
          ),
          onRetry: () => context.read<HistoryBloc>().add(const LoadHistory()),
        ),
      HistoryStatus.empty when !state.hasWorkouts =>
        PremiumEmptyState.noWorkouts(
          onStartActivity: () =>
              MainNavigation.goToTab(context, MainTab.activity),
        ),
      HistoryStatus.empty when state.searchQuery.trim().isNotEmpty =>
        PremiumEmptyState.noSearchResults(
          onClearSearch: () =>
              context.read<HistoryBloc>().add(const SearchWorkout('')),
        ),
      HistoryStatus.empty => PremiumEmptyState.filteredEmpty(
          onClearFilters: () {
            context.read<HistoryBloc>().add(const SearchWorkout(''));
            context.read<HistoryBloc>().add(
                  const FilterWorkout(HistoryFilter.allTime),
                );
          },
        ),
      HistoryStatus.loaded => RefreshIndicator(
          color: AppColorPalette.primary,
          backgroundColor: AppColorPalette.darkCard,
          onRefresh: () async {
            context.read<HistoryBloc>().add(const LoadHistory());
            await context.read<HistoryBloc>().stream.firstWhere(
                  (next) =>
                      next.status != HistoryStatus.loading &&
                      next.status != HistoryStatus.deleting,
                );
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxxl,
            ),
            itemCount: state.visibleWorkouts.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final workout = state.visibleWorkouts[index];
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: WorkoutHistoryCard(
                  key: ValueKey(workout.id),
                  workout: workout,
                  searchQuery: state.searchQuery,
                  onTap: () => context.push(
                    RouteConstants.historyDetailPath(workout.id!),
                  ),
                ),
              );
            },
          ),
        ),
    };
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.selectedSort,
    required this.onSortSelected,
  });

  final HistorySort selectedSort;
  final ValueChanged<HistorySort> onSortSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<HistorySort>(
      initialValue: selectedSort,
      tooltip: 'Sort workouts',
      icon: const Icon(
        Icons.sort_rounded,
        color: AppColorPalette.white,
      ),
      color: AppColorPalette.darkCard,
      onSelected: onSortSelected,
      itemBuilder: (context) {
        return HistorySort.values
            .map(
              (sort) => PopupMenuItem<HistorySort>(
                value: sort,
                child: Text(
                  sort.label,
                  style: TextStyle(
                    color: sort == selectedSort
                        ? AppColorPalette.primaryLight
                        : AppColorPalette.white,
                    fontWeight: sort == selectedSort
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            )
            .toList();
      },
    );
  }
}
