/// Maps persisted activity type strings to analytics distribution buckets.
enum ActivityCategory {
  walking,
  running,
  cycling,
  other,
}

abstract final class ActivityCategoryMapper {
  static ActivityCategory categorize(String activityType) {
    final normalized = activityType.toLowerCase();

    if (normalized.contains('walk') ||
        normalized.contains('hike') ||
        normalized.contains('step')) {
      return ActivityCategory.walking;
    }

    if (normalized.contains('run') || normalized.contains('jog')) {
      return ActivityCategory.running;
    }

    if (normalized.contains('cycl') ||
        normalized.contains('bike') ||
        normalized.contains('bik')) {
      return ActivityCategory.cycling;
    }

    return ActivityCategory.other;
  }
}
