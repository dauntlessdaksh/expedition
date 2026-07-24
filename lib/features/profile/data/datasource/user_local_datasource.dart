import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../models/user_model.dart';

/// Data source for local user persistence via Drift.
class UserLocalDataSource {
  const UserLocalDataSource(this._database);

  final AppDatabase _database;

  Future<bool> hasUser() async {
    final users = await _database.select(_database.users).get();
    return users.isNotEmpty;
  }

  Future<UserModel?> getUser() async {
    final user = await (_database.select(_database.users)
          ..limit(1))
        .getSingleOrNull();

    if (user == null) return null;
    return _mapToModel(user);
  }

  Future<UserModel> createUser({
    required String name,
    required DateTime dateOfBirth,
    required String gender,
    required double height,
    required double weight,
  }) async {
    final id = await _database.into(_database.users).insert(
          UsersCompanion.insert(
            name: name,
            dateOfBirth: dateOfBirth,
            gender: gender,
            height: height,
            weight: weight,
          ),
        );

    final user = await (_database.select(_database.users)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingle();

    return _mapToModel(user);
  }

  Future<UserModel> updateAvatar({
    required int userId,
    required String gender,
    required String hairStyle,
    required String skinTone,
    required String outfitColor,
  }) async {
    await (_database.update(_database.users)
          ..where((tbl) => tbl.id.equals(userId)))
        .write(
      UsersCompanion(
        gender: Value(gender),
        hairStyle: Value(hairStyle),
        skinTone: Value(skinTone),
        outfitColor: Value(outfitColor),
      ),
    );

    final user = await (_database.select(_database.users)
          ..where((tbl) => tbl.id.equals(userId)))
        .getSingle();

    return _mapToModel(user);
  }

  UserModel _mapToModel(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      dateOfBirth: user.dateOfBirth,
      gender: user.gender,
      height: user.height,
      weight: user.weight,
      hairStyle: user.hairStyle,
      skinTone: user.skinTone,
      outfitColor: user.outfitColor,
      createdAt: user.createdAt,
    );
  }
}
