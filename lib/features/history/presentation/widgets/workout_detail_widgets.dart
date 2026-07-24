import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../activity/presentation/utils/activity_formatters.dart';
import '../../domain/models/workout_pace_sample.dart';
import '../../domain/models/workout_split.dart';
import '../../domain/services/workout_analytics.dart';

/// Animated vertical bar chart for workout pace over time.
class WorkoutPaceAnalysisCard extends StatefulWidget {
  const WorkoutPaceAnalysisCard({
    required this.samples,
    required this.averagePaceSeconds,
    this.animationOffset = 0,
    super.key,
  });

  final List<WorkoutPaceSample> samples;
  final double averagePaceSeconds;
  final int animationOffset;

  @override
  State<WorkoutPaceAnalysisCard> createState() =>
      _WorkoutPaceAnalysisCardState();
}

class _WorkoutPaceAnalysisCardState extends State<WorkoutPaceAnalysisCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    Future<void>.delayed(Duration(milliseconds: widget.animationOffset * 45), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validSamples = widget.samples
        .where((sample) => sample.paceSecondsPerKm > 0)
        .toList();

    final fastest = validSamples.isEmpty
        ? 0.0
        : validSamples
            .map((s) => s.paceSecondsPerKm)
            .reduce((a, b) => a < b ? a : b);
    final slowest = validSamples.isEmpty
        ? 0.0
        : validSamples
            .map((s) => s.paceSecondsPerKm)
            .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard.withValues(alpha: 0.72),
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pace',
            style: TextStyle(
              color: AppColorPalette.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Average Pace',
            style: TextStyle(color: AppColorPalette.grey500, fontSize: 13),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _PaceMetric(
                label: 'Average',
                value: WorkoutAnalytics.formatPace(widget.averagePaceSeconds),
              ),
              _PaceMetric(
                label: 'Fastest',
                value: WorkoutAnalytics.formatPace(fastest),
              ),
              _PaceMetric(
                label: 'Slowest',
                value: WorkoutAnalytics.formatPace(slowest),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (validSamples.isEmpty)
            const SizedBox(
              height: 140,
              child: Center(
                child: Text(
                  'Not enough data for pace chart',
                  style: TextStyle(color: AppColorPalette.grey500),
                ),
              ),
            )
          else
            _PaceBarChart(
              samples: widget.samples,
              progress: _controller,
            ),
        ],
      ),
    );
  }
}

class _PaceMetric extends StatelessWidget {
  const _PaceMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColorPalette.grey500,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColorPalette.success,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaceBarChart extends StatelessWidget {
  const _PaceBarChart({
    required this.samples,
    required this.progress,
  });

  final List<WorkoutPaceSample> samples;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final validSamples =
        samples.where((sample) => sample.paceSecondsPerKm > 0).toList();
    if (validSamples.isEmpty) {
      return const SizedBox.shrink();
    }

    final minPace = validSamples
        .map((sample) => sample.paceSecondsPerKm)
        .reduce((a, b) => a < b ? a : b);
    final maxPace = validSamples
        .map((sample) => sample.paceSecondsPerKm)
        .reduce((a, b) => a > b ? a : b);
    final range = (maxPace - minPace).clamp(30, double.infinity);
    const chartHeight = 140.0;
    const barWidth = 6.0;

    final maxElapsed = samples.last.elapsedTimeSeconds;
    final timeLabels = _timeLabels(maxElapsed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: chartHeight,
            child: AnimatedBuilder(
              animation: progress,
              builder: (context, _) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (final sample in samples)
                        Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: _PaceBar(
                            width: barWidth,
                            height: chartHeight,
                            progress: progress.value,
                            normalized: sample.paceSecondsPerKm <= 0
                                ? 0.04
                                : (1 -
                                        ((sample.paceSecondsPerKm - minPace) /
                                            range))
                                    .clamp(0.04, 1.0),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              for (var i = 0; i < timeLabels.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Text(
                  timeLabels[i],
                  style: const TextStyle(
                    color: AppColorPalette.grey500,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<String> _timeLabels(int maxElapsedSeconds) {
    if (maxElapsedSeconds <= 0) {
      return const ['0:00'];
    }

    final labels = <String>[];
    final step = (maxElapsedSeconds / 4).ceil().clamp(60, maxElapsedSeconds);
    for (var second = 0; second <= maxElapsedSeconds; second += step) {
      labels.add(ActivityFormatters.duration(Duration(seconds: second)));
      if (labels.length >= 5) break;
    }
    if (labels.length < 5) {
      labels.add(ActivityFormatters.duration(Duration(seconds: maxElapsedSeconds)));
    }
    return labels;
  }
}

class _PaceBar extends StatelessWidget {
  const _PaceBar({
    required this.width,
    required this.height,
    required this.progress,
    required this.normalized,
  });

  final double width;
  final double height;
  final double progress;
  final double normalized;

  @override
  Widget build(BuildContext context) {
    final barHeight = height * normalized * progress;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
        height: barHeight,
        decoration: BoxDecoration(
          color: AppColorPalette.success.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Premium splits table for workout detail.
class WorkoutSplitsTable extends StatelessWidget {
  const WorkoutSplitsTable({
    required this.splits,
    this.animationOffset = 0,
    super.key,
  });

  final List<WorkoutSplit> splits;
  final int animationOffset;

  @override
  Widget build(BuildContext context) {
    if (splits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColorPalette.darkCard.withValues(alpha: 0.72),
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Splits',
            style: TextStyle(
              color: AppColorPalette.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SplitsHeader(),
          const Divider(color: AppColorPalette.darkCardElevated, height: 24),
          ..._splitRows(splits, animationOffset),
        ],
      ),
    );
  }

  List<Widget> _splitRows(
    List<WorkoutSplit> splits,
    int animationOffset,
  ) {
    final rows = <Widget>[];
    WorkoutSplit? previous;
    for (var i = 0; i < splits.length; i++) {
      final split = splits[i];
      rows.add(
        WorkoutDetailFadeSlide(
          delayMs: (animationOffset + i) * 35,
          child: _SplitRow(
            split: split,
            paceChange: split.paceChangeSecondsComparedTo(previous),
          ),
        ),
      );
      previous = split;
    }
    return rows;
  }
}

class _SplitsHeader extends StatelessWidget {
  const _SplitsHeader();

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColorPalette.grey500,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    );

    return const Row(
      children: [
        Expanded(flex: 2, child: Text('KM', style: style)),
        Expanded(flex: 3, child: Text('TIME', style: style)),
        Expanded(flex: 4, child: Text('PACE', style: style)),
        Expanded(flex: 3, child: Text('CHANGE', style: style)),
      ],
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.split,
    required this.paceChange,
  });

  final WorkoutSplit split;
  final int? paceChange;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      color: AppColorPalette.white,
      fontSize: 15,
      fontWeight: FontWeight.w600,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    Color changeColor = AppColorPalette.grey500;
    if (paceChange != null) {
      changeColor = paceChange! > 0
          ? AppColorPalette.error
          : AppColorPalette.success;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('${split.splitIndex}', style: style)),
          Expanded(
            flex: 3,
            child: Text(
              WorkoutAnalytics.formatSplitTime(split.splitTimeSeconds),
              style: style,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              WorkoutAnalytics.formatPaceShort(split.averagePaceSecondsPerKm),
              style: style,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              WorkoutAnalytics.formatSplitChange(paceChange),
              style: style.copyWith(color: changeColor),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutDetailFadeSlide extends StatefulWidget {
  const WorkoutDetailFadeSlide({
    required this.child,
    this.delayMs = 0,
    super.key,
  });

  final Widget child;
  final int delayMs;

  @override
  State<WorkoutDetailFadeSlide> createState() => _WorkoutDetailFadeSlideState();
}

class _WorkoutDetailFadeSlideState extends State<WorkoutDetailFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Counts up a numeric display when the widget appears.
class AnimatedStatValue extends StatelessWidget {
  const AnimatedStatValue({
    required this.value,
    required this.style,
    super.key,
  });

  final String value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final numeric = double.tryParse(
      value.replaceAll(RegExp(r'[^0-9.]'), ''),
    );

    if (numeric == null) {
      return Text(value, style: style);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: numeric),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        final hasDecimal = value.contains('.');
        final formatted = hasDecimal
            ? animated.toStringAsFixed(2)
            : animated.round().toString();
        final suffix = value.replaceFirst(RegExp(r'^[\d.]+'), '');
        return Text('$formatted$suffix', style: style);
      },
    );
  }
}
