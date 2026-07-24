import 'package:equatable/equatable.dart';

import 'analytics_chart_models.dart';
import 'analytics_records.dart';
import 'analytics_summary.dart';
import 'monthly_trend_range.dart';

/// Aggregated analytics payload rendered by the analytics screen.
class AnalyticsData extends Equatable {
  const AnalyticsData({
    required this.summary,
    required this.weeklyActivity,
    required this.monthlyTrends,
    required this.activityDistribution,
    required this.personalRecords,
    required this.streakStats,
    required this.goalProgress,
    required this.insights,
  });

  final AnalyticsSummary summary;
  final List<AnalyticsWeeklyDay> weeklyActivity;
  final Map<MonthlyTrendRange, List<AnalyticsTrendPoint>> monthlyTrends;
  final ActivityDistribution activityDistribution;
  final PersonalRecords personalRecords;
  final StreakStats streakStats;
  final List<GoalProgressItem> goalProgress;
  final List<String> insights;

  bool get isEmpty => summary.totalWorkouts == 0;

  @override
  List<Object?> get props => [
        summary,
        weeklyActivity,
        monthlyTrends,
        activityDistribution,
        personalRecords,
        streakStats,
        goalProgress,
        insights,
      ];
}
