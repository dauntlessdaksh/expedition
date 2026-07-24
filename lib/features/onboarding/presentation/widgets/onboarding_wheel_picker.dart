import 'package:flutter/cupertino.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/premium_gradients.dart';

/// Premium wheel picker for numeric onboarding values.
class OnboardingWheelPicker extends StatefulWidget {
  const OnboardingWheelPicker({
    required this.values,
    required this.selectedIndex,
    required this.onChanged,
    required this.unit,
    super.key,
  });

  final List<String> values;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String unit;

  @override
  State<OnboardingWheelPicker> createState() => _OnboardingWheelPickerState();
}

class _OnboardingWheelPickerState extends State<OnboardingWheelPicker> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.selectedIndex.clamp(0, widget.values.length - 1),
    );
  }

  @override
  void didUpdateWidget(OnboardingWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex &&
        _controller.selectedItem != widget.selectedIndex) {
      _controller.jumpToItem(
        widget.selectedIndex.clamp(0, widget.values.length - 1),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        gradient: PremiumGradients.cardShimmer,
        borderRadius: AppBorderRadius.radiusXl,
        border: Border.all(
          color: AppColorPalette.darkCardElevated.withValues(alpha: 0.6),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColorPalette.primary.withValues(alpha: 0.08),
                borderRadius: AppBorderRadius.radiusMd,
                border: Border.all(
                  color: AppColorPalette.primary.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CupertinoPicker(
                  scrollController: _controller,
                  itemExtent: 44,
                  magnification: 1.15,
                  squeeze: 1.1,
                  useMagnifier: true,
                  onSelectedItemChanged: widget.onChanged,
                  selectionOverlay: const SizedBox.shrink(),
                  children: widget.values
                      .map(
                        (value) => Center(
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: AppColorPalette.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xxl),
                child: Text(
                  widget.unit,
                  style: const TextStyle(
                    color: AppColorPalette.primaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
