import 'package:hive_ce/hive.dart';

import '../../../domain/entities/user_profile.dart';

part 'user_profile_hive_model.g.dart';

/// Formato de guardado de [UserProfile]. El typeId y los índices de campo son
/// los que ya existen en disco: NO deben cambiar (SPECIFICATION 3.4).
@HiveType(typeId: 1)
class UserProfileHiveModel {
  const UserProfileHiveModel({
    required this.isPremium,
    required this.isSoundEnabled,
  });

  factory UserProfileHiveModel.fromEntity(UserProfile entity) {
    return UserProfileHiveModel(
      isPremium: entity.isPremium,
      isSoundEnabled: entity.isSoundEnabled,
    );
  }

  @HiveField(0)
  final bool isPremium;
  @HiveField(1)
  final bool isSoundEnabled;

  UserProfile toEntity() {
    return UserProfile(
      isPremium: isPremium,
      isSoundEnabled: isSoundEnabled,
    );
  }
}
