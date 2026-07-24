import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/skeleton/skeleton_loaders.dart';
import '../../../../core/widgets/skeleton/skeleton_shimmer.dart';
import '../../../home/presentation/widgets/home_animated_section.dart';
import '../../data/repositories/gamification_repository.dart';
import '../../domain/models/gamification_models.dart';
import '../bloc/achievement_bloc.dart';
import '../bloc/challenge_bloc.dart';
import '../bloc/goal_bloc.dart';
import '../widgets/gamification_achievement_grid.dart';
import '../widgets/gamification_challenge_section.dart';
import '../widgets/gamification_goal_section.dart';
import '../widgets/gamification_milestone_timeline.dart';
import '../widgets/gamification_stats_header.dart';

/// Gamification hub with achievements, goals, challenges, and milestones.
class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen> {
  GamificationStats? _stats;
  List<Milestone> _milestones = const [];
  bool _isLoadingExtras = true;

  @override
  void initState() {
    super.initState();
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    final repository = context.read<GamificationRepository>();
    final stats = await repository.getStats();
    final milestones = await repository.getMilestones();
    if (!mounted) return;
    setState(() {
      _stats = stats;
      _milestones = milestones;
      _isLoadingExtras = false;
    });
  }

  Future<void> _refreshAll() async {
    context.read<AchievementBloc>().add(const RefreshAchievements());
    context.read<GoalBloc>().add(const RefreshGoals());
    context.read<ChallengeBloc>().add(const RefreshChallenges());
    await _loadExtras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorPalette.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Rewards'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: PremiumGradients.darkBackground,
        ),
        child: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, achievementState) {
            return BlocBuilder<GoalBloc, GoalState>(
              builder: (context, goalState) {
                return BlocBuilder<ChallengeBloc, ChallengeState>(
                  builder: (context, challengeState) {
                    if (achievementState.status == AchievementStatus.loading &&
                        achievementState.achievements.isEmpty) {
                      return SkeletonLoaders.gamification();
                    }

                    return RefreshIndicator(
                      color: AppColorPalette.primary,
                      backgroundColor: AppColorPalette.darkCard,
                      onRefresh: _refreshAll,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.xxl,
                              AppSpacing.sm,
                              AppSpacing.xxl,
                              AppSpacing.xxxl,
                            ),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                if (_isLoadingExtras || _stats == null)
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      bottom: AppSpacing.xl,
                                    ),
                                    child: SkeletonBox(
                                      width: double.infinity,
                                      height: 160,
                                    ),
                                  )
                                else
                                  HomeAnimatedSection(
                                    index: 0,
                                    child: GamificationStatsHeader(
                                      stats: _stats!,
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.xl),
                                if (goalState.status == GoalStatus.loaded)
                                  HomeAnimatedSection(
                                    index: 1,
                                    child: GamificationGoalSection(
                                      goals: goalState.goals,
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.xl),
                                if (challengeState.status ==
                                    ChallengeStatus.loaded)
                                  HomeAnimatedSection(
                                    index: 2,
                                    child: GamificationChallengeSection(
                                      challenges: challengeState.challenges,
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.xl),
                                if (achievementState.status ==
                                    AchievementStatus.loaded)
                                  HomeAnimatedSection(
                                    index: 3,
                                    child: GamificationAchievementGrid(
                                      achievements:
                                          achievementState.achievements,
                                    ),
                                  ),
                                const SizedBox(height: AppSpacing.xl),
                                if (!_isLoadingExtras)
                                  HomeAnimatedSection(
                                    index: 4,
                                    child: GamificationMilestoneTimeline(
                                      milestones: _milestones,
                                    ),
                                  ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
