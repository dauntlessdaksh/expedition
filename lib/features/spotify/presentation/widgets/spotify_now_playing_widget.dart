import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_border_radius.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../bloc/spotify_bloc.dart';
import 'spotify_player_sheet.dart';

/// Compact "Now Playing" card for the home dashboard.
class SpotifyNowPlayingWidget extends StatelessWidget {
  const SpotifyNowPlayingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpotifyBloc, SpotifyState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.track != current.track ||
          previous.isPlaying != current.isPlaying,
      builder: (context, state) {
        if (!state.isConnected || !state.hasTrack) {
          return const SizedBox.shrink();
        }

        final track = state.track!;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => SpotifyPlayerSheet.show(
                    context,
                    bloc: context.read<SpotifyBloc>(),
                  ),
              borderRadius: AppBorderRadius.radiusLg,
              child: Ink(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColorPalette.darkCard.withValues(alpha: 0.92),
                  borderRadius: AppBorderRadius.radiusLg,
                  border: Border.all(
                    color: AppColorPalette.darkCardElevated.withValues(alpha: 0.65),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 44,
                        height: 44,
                        color: AppColorPalette.darkCardElevated,
                        child: track.albumArtUrl == null
                            ? const Icon(
                                Icons.music_note_rounded,
                                color: AppColorPalette.success,
                              )
                            : Image.network(
                                track.albumArtUrl!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              color: AppColorPalette.success.withValues(alpha: 0.9),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColorPalette.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColorPalette.grey400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      state.isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                      color: AppColorPalette.white,
                      size: 30,
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
