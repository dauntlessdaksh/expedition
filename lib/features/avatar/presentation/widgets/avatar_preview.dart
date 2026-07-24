import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';
import '../../../../core/widgets/selection_chip.dart';

/// Maps skin tone names to display colors for the avatar placeholder.
abstract final class AvatarColorMapper {
  static Color skinTone(String tone) {
    return switch (tone.toLowerCase()) {
      'light' => const Color(0xFFFFDBB4),
      'medium' => const Color(0xFFE0AC69),
      'tan' => const Color(0xFFC68642),
      'dark' => const Color(0xFF8D5524),
      'deep' => const Color(0xFF5C3317),
      _ => const Color(0xFFE0AC69),
    };
  }

  static Color outfit(String color) {
    return switch (color.toLowerCase()) {
      'teal' => AppColorPalette.primary,
      'coral' => AppColorPalette.accent,
      'black' => AppColorPalette.grey900,
      'white' => AppColorPalette.grey100,
      'navy' => const Color(0xFF1E3A5F),
      _ => AppColorPalette.primary,
    };
  }

  static IconData hairStyleIcon(String style) {
    return switch (style.toLowerCase()) {
      'short' => Icons.face,
      'medium' => Icons.face_3,
      'long' => Icons.face_4,
      'curly' => Icons.face_5,
      'bald' => Icons.face_6,
      _ => Icons.person,
    };
  }
}

/// Placeholder avatar preview designed for future 3D model integration.
class AvatarPreview extends StatelessWidget {
  const AvatarPreview({
    required this.gender,
    required this.hairStyle,
    required this.skinTone,
    required this.outfitColor,
    super.key,
  });

  final String gender;
  final String hairStyle;
  final String skinTone;
  final String outfitColor;

  @override
  Widget build(BuildContext context) {
    final skin = AvatarColorMapper.skinTone(skinTone);
    final outfit = AvatarColorMapper.outfit(outfitColor);

    return Container(
      width: 180,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: PremiumGradients.cardShimmer,
        border: Border.all(
          color: AppColorPalette.primary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.primary.withValues(alpha: 0.15),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: PremiumGradients.avatarRing(outfit),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: skin,
              ),
              child: Icon(
                gender.toLowerCase() == 'female'
                    ? Icons.face_3
                    : Icons.face,
                size: 52,
                color: skin.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: outfit,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            hairStyle,
            style: const TextStyle(
              color: AppColorPalette.grey400,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal scrollable option selector for avatar customization.
class AvatarOptionSelector extends StatelessWidget {
  const AvatarOptionSelector({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColorPalette.grey300,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: SelectionChip(
                  label: option,
                  isSelected: selected == option,
                  onTap: () => onSelected(option),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Color swatch selector for outfit colors.
class OutfitColorSelector extends StatelessWidget {
  const OutfitColorSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Outfit Color',
          style: TextStyle(
            color: AppColorPalette.grey300,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: options.map((option) {
            final color = AvatarColorMapper.outfit(option);
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: AppSpacing.md),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColorPalette.white
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: AppColorPalette.white,
                        size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Skin tone swatch selector.
class SkinToneSelector extends StatelessWidget {
  const SkinToneSelector({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Skin Tone',
          style: TextStyle(
            color: AppColorPalette.grey300,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: options.map((option) {
            final color = AvatarColorMapper.skinTone(option);
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () => onSelected(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: AppSpacing.md),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColorPalette.primaryLight
                        : AppColorPalette.darkCardElevated,
                    width: isSelected ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
