import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../bloc/spotify_bloc.dart';
import 'spotify_player_sheet.dart';

/// Compact floating Spotify controller shown during workouts.
class SpotifyMiniPlayer extends StatelessWidget {
  const SpotifyMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpotifyBloc, SpotifyState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.track != current.track ||
          previous.isPlaying != current.isPlaying ||
          previous.positionMs != current.positionMs ||
          previous.durationMs != current.durationMs,
      builder: (context, state) {
        if (!state.isConnected) {
          return const SizedBox.shrink();
        }

        final track = state.track;
        final progress = state.durationMs <= 0
            ? 0.0
            : (state.positionMs / state.durationMs).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => SpotifyPlayerSheet.show(
                    context,
                    bloc: context.read<SpotifyBloc>(),
                  ),
              borderRadius: AppBorderRadius.radiusXl,
              child: Ink(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColorPalette.darkCard.withValues(alpha: 0.96),
                  borderRadius: AppBorderRadius.radiusXl,
                  border: Border.all(
                    color: AppColorPalette.darkCardElevated.withValues(alpha: 0.7),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColorPalette.black.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            _AlbumArtwork(
                              imageUrl: track?.albumArtUrl,
                              size: 52,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track?.name ?? 'Nothing playing',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColorPalette.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    track?.artist ?? 'Open Spotify to start music',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColorPalette.grey400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _TransportButton(
                              icon: Icons.skip_previous_rounded,
                              onPressed: () => context
                                  .read<SpotifyBloc>()
                                  .add(const PreviousPressed()),
                            ),
                            _TransportButton(
                              icon: state.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              filled: true,
                              onPressed: () {
                                final bloc = context.read<SpotifyBloc>();
                                if (state.isPlaying) {
                                  bloc.add(const PausePressed());
                                } else {
                                  bloc.add(const PlayPressed());
                                }
                              },
                            ),
                            _TransportButton(
                              icon: Icons.skip_next_rounded,
                              onPressed: () => context
                                  .read<SpotifyBloc>()
                                  .add(const NextPressed()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor:
                            AppColorPalette.darkCardElevated.withValues(alpha: 0.5),
                        color: AppColorPalette.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AlbumArtwork extends StatelessWidget {
  const _AlbumArtwork({
    required this.imageUrl,
    required this.size,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          color: AppColorPalette.darkCardElevated,
          child: imageUrl == null || imageUrl!.isEmpty
              ? const Icon(
                  Icons.library_music_rounded,
                  color: Color(0xFF4ADE80),
                  size: 26,
                )
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: 52,
                  height: 52,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.library_music_rounded,
                    color: Color(0xFF4ADE80),
                    size: 26,
                  ),
                ),
        ),
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({
    required this.icon,
    required this.onPressed,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: filled ? AppColorPalette.black : AppColorPalette.white,
      ),
      style: IconButton.styleFrom(
        backgroundColor: filled
            ? AppColorPalette.white
            : AppColorPalette.black.withValues(alpha: 0.25),
        minimumSize: Size(filled ? 40 : 34, filled ? 40 : 34),
      ),
    );
  }
}
