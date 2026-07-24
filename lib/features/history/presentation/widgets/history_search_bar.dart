import 'package:flutter/material.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/models/history_filter.dart';

/// Search field for filtering workouts by activity name.
class HistorySearchBar extends StatelessWidget {
  const HistorySearchBar({
    required this.query,
    required this.onChanged,
    super.key,
  });

  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppColorPalette.white),
      decoration: InputDecoration(
        hintText: 'Search activity',
        hintStyle: const TextStyle(color: AppColorPalette.grey500),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: AppColorPalette.grey400,
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: () => onChanged(''),
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColorPalette.grey400,
                ),
              ),
        filled: true,
        fillColor: AppColorPalette.darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusLg,
          borderSide: BorderSide(
            color: AppColorPalette.grey700.withValues(alpha: 0.6),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusLg,
          borderSide: BorderSide(
            color: AppColorPalette.grey700.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.radiusLg,
          borderSide: BorderSide(
            color: AppColorPalette.primary.withValues(alpha: 0.8),
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
              color: isSelected
                  ? AppColorPalette.white
                  : AppColorPalette.grey300,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            backgroundColor: AppColorPalette.darkCard,
            selectedColor: AppColorPalette.primary.withValues(alpha: 0.35),
            side: BorderSide(
              color: isSelected
                  ? AppColorPalette.primary.withValues(alpha: 0.6)
                  : AppColorPalette.grey700.withValues(alpha: 0.6),
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
