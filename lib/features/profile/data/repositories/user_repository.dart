import '../datasource/user_local_datasource.dart';
import '../models/user_model.dart';

/// Repository for user profile operations.
class UserRepository {
  const UserRepository(this._localDataSource);

  final UserLocalDataSource _localDataSource;

  Future<bool> hasUser() => _localDataSource.hasUser();

  Future<UserModel?> getUser() => _localDataSource.getUser();

  Future<UserModel> createUser({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required double height,
    required double weight,
  }) {
    return _localDataSource.createUser(
      name: name,
      dateOfBirth: dateOfBirth,
      gender: gender,
      height: height,
      weight: weight,
    );
  }

  Future<UserModel> updateAvatar({
    required int userId,
    required String gender,
    required String hairStyle,
    required String skinTone,
    required String outfitColor,
  }) {
    return _localDataSource.updateAvatar(
      userId: userId,
      gender: gender,
      hairStyle: hairStyle,
      skinTone: skinTone,
      outfitColor: outfitColor,
    );
  }
}
