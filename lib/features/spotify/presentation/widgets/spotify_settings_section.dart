import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../settings/presentation/widgets/settings_group_card.dart';
import '../bloc/spotify_bloc.dart';

/// Spotify connect / disconnect controls for Settings.
class SpotifySettingsSection extends StatelessWidget {
  const SpotifySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SpotifyBloc, SpotifyState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null && message.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      builder: (context, state) {
        final isLinked = state.isLinked;
        final isLoading = state.isLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSectionLabel('Spotify'),
            SettingsGroupCard(
              child: Column(
                children: [
                  if (isLinked) ...[
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF1DB954),
                        ),
                      ),
                      title: const Text(
                        'Connected Account',
                        style: TextStyle(
                          color: AppColorPalette.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        state.accountLabel ??
                            (state.isConnected
                                ? 'Spotify Premium account'
                                : 'Linked — tap music during a workout to connect playback'),
                        style: const TextStyle(color: AppColorPalette.grey400),
                      ),
                    ),
                    const Divider(
                      height: 1,
                      color: AppColorPalette.darkCardElevated,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.link_off_rounded,
                        color: AppColorPalette.error,
                      ),
                      title: const Text(
                        'Disconnect',
                        style: TextStyle(
                          color: AppColorPalette.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: isLoading
                          ? null
                          : () => context
                              .read<SpotifyBloc>()
                              .add(const DisconnectSpotify()),
                    ),
                  ] else
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1DB954).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Color(0xFF1DB954),
                        ),
                      ),
                      title: const Text(
                        'Connect Spotify',
                        style: TextStyle(
                          color: AppColorPalette.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Control playback without leaving Expedition',
                        style: TextStyle(color: AppColorPalette.grey400),
                      ),
                      trailing: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColorPalette.grey500,
                            ),
                      onTap: isLoading
                          ? null
                          : () => context
                              .read<SpotifyBloc>()
                              .add(const ConnectSpotify()),
                    ),
                ],
              ),
            ),
            const SettingsSectionHint(
              'Requires the Spotify app on your device. Playback is controlled through Spotify App Remote.',
            ),
          ],
        );
      },
    );
  }
}
