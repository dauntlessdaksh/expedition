import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../home/presentation/bloc/home_bloc.dart';
import '../../domain/models/workout.dart';
import '../bloc/history_bloc.dart';
import '../widgets/workout_route_map.dart';
import '../../../shared/utils/workout_display_formatters.dart';

/// Detailed summary for a single saved workout.
class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({
    required this.workoutId,
    super.key,
  });

  final int workoutId;

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryBloc>().add(LoadWorkoutDetail(widget.workoutId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HistoryBloc, HistoryState>(
      listenWhen: (previous, current) =>
          previous.deletedWorkoutId != current.deletedWorkoutId ||
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.deletedWorkoutId == widget.workoutId) {
          _refreshHomeDashboard(context);
          if (context.mounted) {
            context.pop();
          }
          return;
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context.read<HistoryBloc>().add(const ClearHistoryMessage());
        }
      },
      builder: (context, state) {
        final workout = _resolveWorkout(state);

        if (workout == null &&
            (state.status == HistoryStatus.loading ||
                state.status == HistoryStatus.initial ||
                state.status == HistoryStatus.deleting)) {
          return const Scaffold(
            backgroundColor: AppColorPalette.darkBackground,
            body: LoadingIndicator(message: 'Loading workout...'),
          );
        }

        if (workout == null) {
          return Scaffold(
            backgroundColor: AppColorPalette.darkBackground,
            appBar: AppBar(
              backgroundColor: AppColorPalette.darkBackground,
              foregroundColor: AppColorPalette.white,
              elevation: 0,
            ),
            body: const Center(
              child: Text(
                'Workout not found',
                style: TextStyle(color: AppColorPalette.grey400),
              ),
            ),
          );
        }

        return _WorkoutDetailContent(
          workout: workout,
          isDeleting: state.status == HistoryStatus.deleting,
        );
      },
    );
  }

  Workout? _resolveWorkout(HistoryState state) {
    if (state.focusedWorkout?.id == widget.workoutId) {
      return state.focusedWorkout;
    }

    for (final workout in state.allWorkouts) {
      if (workout.id == widget.workoutId) {
        return workout;
      }
    }

    for (final workout in state.visibleWorkouts) {
      if (workout.id == widget.workoutId) {
        return workout;
      }
    }

    return null;
  }

  void _refreshHomeDashboard(BuildContext context) {
    try {
      context.read<HomeBloc>().add(const RefreshDashboard());
    } on Exception {
      // Home is not in the widget tree when history was opened via go().
    }
  }
}

class _WorkoutDetailContent extends StatelessWidget {
  const _WorkoutDetailContent({
    required this.workout,
    required this.isDeleting,
  });

  final Workout workout;
  final bool isDeleting;

  @override
  Widget build(BuildContext context) {
    final activityLabel =
        WorkoutDisplayFormatters.activityType(workout.activityType);

    return Scaffold(
      backgroundColor: AppColorPalette.darkBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: AppColorPalette.darkBackground,
            foregroundColor: AppColorPalette.white,
            leading: IconButton(
              onPressed: isDeleting ? null : () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
                  );
                },
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: PremiumGradients.darkBackground,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      56,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Hero(
                          tag: 'workout-icon-${workout.id}',
                          child: _DetailIcon(activityType: workout.activityType),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Hero(
                          tag: 'workout-title-${workout.id}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              activityLabel,
                              style: const TextStyle(
                                color: AppColorPalette.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          WorkoutDisplayFormatters.workoutDateShort(
                            workout.startTime,
                          ),
                          style: const TextStyle(
                            color: AppColorPalette.grey400,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            _HeroMetric(
                              label: 'Duration',
                              value: WorkoutDisplayFormatters.durationSeconds(
                                workout.durationInSeconds,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xl),
                            _HeroMetric(
                              label: 'Distance',
                              value: WorkoutDisplayFormatters.distanceMeters(
                                workout.distanceInMeters,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: AppBorderRadius.radiusXl,
                    child: SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: WorkoutRouteMap(routePoints: workout.polyline),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _StatsGrid(workout: workout),
                  const SizedBox(height: AppSpacing.lg),
                  _DeleteButton(
                    isLoading: isDeleting,
                    onPressed: isDeleting
                        ? null
                        : () => _confirmDelete(context),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColorPalette.darkCard,
          title: const Text(
            'Delete Workout',
            style: TextStyle(color: AppColorPalette.white),
          ),
          content: const Text(
            'This workout will be permanently removed from your history.',
            style: TextStyle(color: AppColorPalette.grey300),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColorPalette.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    context.read<HistoryBloc>().add(DeleteWorkout(workout.id!));
  }
}

class _DetailIcon extends StatelessWidget {
  const _DetailIcon({required this.activityType});

  final String activityType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColorPalette.primary.withValues(alpha: 0.18),
        borderRadius: AppBorderRadius.radiusMd,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.35),
        ),
      ),
      child: const Icon(
        Icons.directions_run_rounded,
        color: AppColorPalette.primaryLight,
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColorPalette.grey500,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: AppColorPalette.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(
        label: 'Distance',
        value: WorkoutDisplayFormatters.distanceMeters(workout.distanceInMeters),
      ),
      _StatItem(
        label: 'Duration',
        value: WorkoutDisplayFormatters.durationSeconds(workout.durationInSeconds),
      ),
      _StatItem(
        label: 'Average Speed',
        value: WorkoutDisplayFormatters.speedMps(workout.averageSpeed),
      ),
      _StatItem(
        label: 'Calories',
        value: '${workout.calories} kcal',
      ),
      _StatItem(
        label: 'Start Time',
        value: WorkoutDisplayFormatters.timeOfDay(workout.startTime),
      ),
      _StatItem(
        label: 'End Time',
        value: WorkoutDisplayFormatters.timeOfDay(workout.endTime),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: PremiumGradients.cardShimmer,
            borderRadius: AppBorderRadius.radiusLg,
            border: Border.all(
              color: AppColorPalette.darkCardElevated.withValues(alpha: 0.65),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: const TextStyle(
                  color: AppColorPalette.grey400,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                stat.value,
                style: const TextStyle(
                  color: AppColorPalette.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.delete_outline_rounded),
        label: Text(isLoading ? 'Deleting...' : 'Delete Workout'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorPalette.error,
          side: BorderSide(
            color: AppColorPalette.error.withValues(alpha: 0.55),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.radiusLg,
          ),
        ),
      ),
    );
  }
}
