/// Asset path constants for the Expedition application.
abstract final class AppAssets {
  static const String _imagesBase = 'assets/images';
  static const String _iconsBase = 'assets/icons';

  // Images
  static const String logo = '$_imagesBase/logo.png';
  static const String placeholderAvatar = '$_imagesBase/placeholder_avatar.png';

  // Icons
  static const String iconRun = '$_iconsBase/run.svg';
  static const String iconWalk = '$_iconsBase/walk.svg';
  static const String iconCycle = '$_iconsBase/cycle.svg';

  // 3D Avatars
  static const String _avatarsBase = 'assets/avatars';
  static const String maleRunningGlb = '$_avatarsBase/male/malerunning.glb';
  static const String maleDancingGlb = '$_avatarsBase/male/maledancing.glb';
  static const String femaleRunningGlb = '$_avatarsBase/female/femrunning.glb';
  static const String femaleDancingGlb = '$_avatarsBase/female/femdancing.glb';
}
