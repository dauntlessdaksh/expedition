import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../data/models/spotify_player_state.dart';
import '../bloc/spotify_bloc.dart';
import '../utils/spotify_formatters.dart';

/// Full-screen Spotify player sheet with premium Expedition styling.
class SpotifyPlayerSheet extends StatefulWidget {
  const SpotifyPlayerSheet({super.key});

  static bool _isOpen = false;

  /// Opens the player sheet. Pass [bloc] when calling after async work
  /// (e.g. Spotify auth) so the caller's [context] is not read when stale.
  static Future<void> show(
    BuildContext context, {
    required SpotifyBloc bloc,
  }) {
    if (_isOpen || !context.mounted) {
      return Future<void>.value();
    }

    _isOpen = true;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: const SpotifyPlayerSheet(),
      ),
    ).whenComplete(() => _isOpen = false);
  }

  @override
  State<SpotifyPlayerSheet> createState() => _SpotifyPlayerSheetState();
}

class _SpotifyPlayerSheetState extends State<SpotifyPlayerSheet> {
  double? _dragPositionMs;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColorPalette.darkCard.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: AppColorPalette.darkCardElevated.withValues(alpha: 0.7),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColorPalette.black.withValues(alpha: 0.45),
                blurRadius: 32,
                offset: const Offset(0, -12),
              ),
            ],
          ),
          child: BlocBuilder<SpotifyBloc, SpotifyState>(
            builder: (context, state) {
              final track = state.track;
              final positionMs = _dragPositionMs ?? state.positionMs.toDouble();
              final durationMs =
                  state.durationMs > 0 ? state.durationMs.toDouble() : 1.0;

              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.xxxl,
                ),
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColorPalette.grey600.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: _LargeAlbumArt(imageUrl: track?.albumArtUrl),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    track?.name ?? 'Nothing playing',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColorPalette.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    track?.artist ?? 'Start playback in Spotify',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColorPalette.grey400,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: AppColorPalette.success,
                      inactiveTrackColor:
                          AppColorPalette.darkCardElevated.withValues(alpha: 0.8),
                      thumbColor: AppColorPalette.white,
                    ),
                    child: Slider(
                      value: positionMs.clamp(0, durationMs),
                      max: durationMs,
                      onChangeStart: (_) => _dragPositionMs = state.positionMs.toDouble(),
                      onChanged: (value) => setState(() => _dragPositionMs = value),
                      onChangeEnd: (value) {
                        context.read<SpotifyBloc>().add(SeekChanged(value.round()));
                        setState(() => _dragPositionMs = null);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          SpotifyFormatters.duration(positionMs.round()),
                          style: const TextStyle(
                            color: AppColorPalette.grey500,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          SpotifyFormatters.duration(state.durationMs),
                          style: const TextStyle(
                            color: AppColorPalette.grey500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SheetControlButton(
                        icon: Icons.skip_previous_rounded,
                        onPressed: () => context
                            .read<SpotifyBloc>()
                            .add(const PreviousPressed()),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _SheetControlButton(
                        icon: state.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        filled: true,
                        size: 72,
                        onPressed: () {
                          final bloc = context.read<SpotifyBloc>();
                          if (state.isPlaying) {
                            bloc.add(const PausePressed());
                          } else {
                            bloc.add(const PlayPressed());
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _SheetControlButton(
                        icon: Icons.skip_next_rounded,
                        onPressed: () =>
                            context.read<SpotifyBloc>().add(const NextPressed()),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shuffle_rounded,
                        size: 18,
                        color: state.isShuffleEnabled
                            ? AppColorPalette.success
                            : AppColorPalette.grey500,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Icon(
                        _repeatIcon(state.repeatMode),
                        size: 18,
                        color: state.repeatMode == SpotifyRepeatMode.off
                            ? AppColorPalette.grey500
                            : AppColorPalette.success,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  IconData _repeatIcon(SpotifyRepeatMode mode) {
    return switch (mode) {
      SpotifyRepeatMode.track => Icons.repeat_one_rounded,
      SpotifyRepeatMode.context => Icons.repeat_rounded,
      SpotifyRepeatMode.off => Icons.repeat_rounded,
    };
  }
}

class _LargeAlbumArt extends StatelessWidget {
  const _LargeAlbumArt({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: AppBorderRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: AppColorPalette.black.withValues(alpha: 0.45),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppBorderRadius.radiusXl,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Container(
                color: AppColorPalette.darkCardElevated,
                child: const Icon(
                  Icons.album_rounded,
                  size: 72,
                  color: AppColorPalette.grey500,
                ),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColorPalette.darkCardElevated,
                  child: const Icon(
                    Icons.album_rounded,
                    size: 72,
                    color: AppColorPalette.grey500,
                  ),
                ),
              ),
      ),
    );
  }
}

class _SheetControlButton extends StatelessWidget {
  const _SheetControlButton({
    required this.icon,
    required this.onPressed,
    this.filled = false,
    this.size = 56,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColorPalette.white : AppColorPalette.darkCardElevated,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            color: filled ? AppColorPalette.black : AppColorPalette.white,
            size: size * 0.42,
          ),
        ),
      ),
    );
  }
}
