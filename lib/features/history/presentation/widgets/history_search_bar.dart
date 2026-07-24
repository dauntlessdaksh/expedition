import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/expedition_colors.dart';
import '../../domain/models/history_filter.dart';

/// Debounced search field for filtering workouts by activity name.
class HistorySearchBar extends StatefulWidget {
  const HistorySearchBar({
    required this.query,
    required this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 320),
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;
  final Duration debounceDuration;

  @override
  State<HistorySearchBar> createState() => _HistorySearchBarState();
}

class _HistorySearchBarState extends State<HistorySearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant HistorySearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return Semantics(
      label: 'Search workouts',
      child: TextField(
        controller: _controller,
        onChanged: _onQueryChanged,
        style: TextStyle(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search activity',
          hintStyle: TextStyle(color: colors.textMuted),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colors.textMuted,
          ),
          suffixIcon: widget.query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    _controller.clear();
                    widget.onChanged('');
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.textMuted,
                  ),
                ),
          filled: true,
          fillColor: colors.cardElevated,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusLg,
            borderSide: BorderSide(color: colors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusLg,
            borderSide: BorderSide(color: colors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppBorderRadius.radiusLg,
            borderSide: BorderSide(
              color: AppColorPalette.primary.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal filter chips for workout history date ranges.
class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({
    required this.selectedFilter,
    required this.onFilterSelected,
    super.key,
  });

  final HistoryFilter selectedFilter;
  final ValueChanged<HistoryFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.expeditionColors;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: HistoryFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final filter = HistoryFilter.values[index];
          final isSelected = filter == selectedFilter;

          return FilterChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => onFilterSelected(filter),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: isSelected ? AppColorPalette.white : colors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            backgroundColor: colors.cardElevated,
            selectedColor: AppColorPalette.primary,
            side: BorderSide(
              color: isSelected
                  ? AppColorPalette.primary
                  : colors.divider,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppBorderRadius.radiusFull,
            ),
          );
        },
      ),
    );
  }
}
