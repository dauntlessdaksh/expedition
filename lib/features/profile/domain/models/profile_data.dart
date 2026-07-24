import 'package:equatable/equatable.dart';

import '../../../onboarding/data/models/user_profile.dart';
import 'profile_models.dart';

/// Achievement badge displayed in the profile screen.
class AchievementBadge extends Equatable {
  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.isEarned,
  });

  final String id;
  final String title;
  final String description;
  final bool isEarned;

  @override
  List<Object?> get props => [id, title, description, isEarned];
}

/// Aggregated profile screen payload.
class ProfileData extends Equatable {
  const ProfileData({
    required this.profile,
    required this.preferences,
    required this.currentStreak,
    required this.achievements,
  });

  final UserProfile profile;
  final UserPreferences preferences;
  final int currentStreak;
  final List<AchievementBadge> achievements;

  @override
  List<Object?> get props => [
        profile,
        preferences,
        currentStreak,
        achievements,
      ];
}

/// Result of exporting workouts to local storage.
class WorkoutExportResult extends Equatable {
  const WorkoutExportResult({
    required this.filePath,
    required this.workoutCount,
  });

  final String filePath;
  final int workoutCount;

  @override
  List<Object?> get props => [filePath, workoutCount];
}
