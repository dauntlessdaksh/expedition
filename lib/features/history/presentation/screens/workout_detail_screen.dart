import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/skeleton/skeleton_loaders.dart';
import '../../domain/models/workout.dart';
import '../../domain/services/workout_analytics.dart';
import '../bloc/history_bloc.dart';
import '../widgets/workout_detail_stats_list.dart';
import '../widgets/workout_detail_widgets.dart';
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
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
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
                state.status == HistoryStatus.initial)) {
          return Scaffold(
            backgroundColor: context.expeditionColors.scaffoldBackground,
            body: SkeletonLoaders.workoutDetail(),
          );
        }

        if (workout == null) {
          final colors = context.expeditionColors;
          return Scaffold(
            backgroundColor: colors.scaffoldBackground,
            appBar: AppBar(
              backgroundColor: colors.scaffoldBackground,
              foregroundColor: colors.textPrimary,
              elevation: 0,
            ),
            body: Center(
              child: Text(
                'Workout not found',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
          );
        }

        return _WorkoutDetailContent(workout: workout);
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
}

class _WorkoutDetailContent extends StatelessWidget {
  const _WorkoutDetailContent({
    required this.workout,
  });

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final activityLabel =
        WorkoutDisplayFormatters.activityType(workout.activityType);
    final paceSamples = WorkoutAnalytics.resolvePaceSamples(workout);
    final splits = WorkoutAnalytics.resolveSplits(workout);
    final avgPace = WorkoutAnalytics.averagePaceSecondsPerKm(
      distanceMeters: workout.distanceInMeters,
      durationSeconds: workout.movingTimeInSeconds > 0
          ? workout.movingTimeInSeconds
          : workout.durationInSeconds,
    );

    final colors = context.expeditionColors;

    return Scaffold(
      backgroundColor: colors.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colors.scaffoldBackground,
            foregroundColor: colors.textPrimary,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkoutDetailFadeSlide(
                  child: SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: WorkoutRouteMap(workout: workout),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WorkoutDetailFadeSlide(
                        delayMs: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activityLabel,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              WorkoutDisplayFormatters.workoutDate(
                                workout.startTime,
                              ),
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              WorkoutDisplayFormatters.durationSeconds(
                                workout.durationInSeconds,
                              ),
                              style: const TextStyle(
                                color: AppColorPalette.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      WorkoutDetailStatsList(
                        workout: workout,
                        animationOffset: 2,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      WorkoutDetailFadeSlide(
                        delayMs: 180,
                        child: WorkoutPaceAnalysisCard(
                          samples: paceSamples,
                          averagePaceSeconds: avgPace,
                          animationOffset: 4,
                        ),
                      ),
                      if (splits.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        WorkoutSplitsTable(
                          splits: splits,
                          animationOffset: 6,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
