/// Outdoor GPS engine lifecycle states.
enum GpsTrackingState {
  /// Acquiring a stable GPS fix before movement detection begins.
  waitingForGpsLock,

  /// Session timer is running but distance/speed are not accumulated yet.
  waitingForMovement,

  /// Actively tracking distance, speed, moving time, and polyline.
  tracking,

  /// Movement has slowed; metrics are frozen while stop is confirmed.
  possibleStop,

  /// Stop confirmed; metrics remain frozen until movement resumes.
  stopped,
}
