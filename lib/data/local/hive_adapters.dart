import 'package:hive/hive.dart';

import '../../domain/entities/level_state.dart';
import '../../domain/entities/user_profile.dart';

const int kLevelStateTypeId = 0;
const int kUserProfileTypeId = 1;

final class LevelStateAdapter extends TypeAdapter<LevelState> {
  @override
  final int typeId = kLevelStateTypeId;

  @override
  LevelState read(BinaryReader reader) {
    final levelId = reader.readString();
    final isCompleted = reader.readBool();
    final stars = reader.readInt();
    if (stars < 0 || stars > 3) {
      throw HiveError('Invalid stars value for "$levelId": $stars');
    }
    return LevelState(
      levelId: levelId,
      isCompleted: isCompleted,
      stars: stars,
    );
  }

  @override
  void write(BinaryWriter writer, LevelState obj) {
    writer
      ..writeString(obj.levelId)
      ..writeBool(obj.isCompleted)
      ..writeInt(obj.stars);
  }
}

final class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = kUserProfileTypeId;

  @override
  UserProfile read(BinaryReader reader) {
    final isPremium = reader.readBool();
    final soundEnabled = reader.readBool();
    return UserProfile(
      isPremium: isPremium,
      soundEnabled: soundEnabled,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeBool(obj.isPremium)
      ..writeBool(obj.soundEnabled);
  }
}
