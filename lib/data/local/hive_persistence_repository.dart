import 'package:hive/hive.dart';

import '../../domain/entities/level_state.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_persistence_repository.dart';

class HivePersistenceRepository implements IPersistenceRepository {
  static const String _userProfileKey = 'current_user_profile';

  const HivePersistenceRepository({
    required Box<LevelState> levelStateBox,
    required Box<UserProfile> userProfileBox,
  })  : _levelStateBox = levelStateBox,
        _userProfileBox = userProfileBox;

  final Box<LevelState> _levelStateBox;
  final Box<UserProfile> _userProfileBox;

  @override
  Future<List<LevelState>> readAllLevelStates() async {
    return _levelStateBox.values.toList(growable: false);
  }

  @override
  Future<LevelState?> readLevelState(String levelId) async {
    return _levelStateBox.get(levelId);
  }

  @override
  Future<void> saveLevelState(LevelState levelState) async {
    await _levelStateBox.put(levelState.levelId, levelState);
  }

  @override
  Future<void> saveLevelStates(Iterable<LevelState> levelStates) async {
    final Map<String, LevelState> levelStateById = {
      for (final levelState in levelStates) levelState.levelId: levelState,
    };

    await _levelStateBox.putAll(levelStateById);
  }

  @override
  Future<UserProfile?> readUserProfile() async {
    final UserProfile? savedProfile = _userProfileBox.get(_userProfileKey) ??
        (_userProfileBox.isNotEmpty ? _userProfileBox.values.first : null);

    return savedProfile ??
        const UserProfile(
          isPremium: false,
          isSoundEnabled: true,
        );
  }

  @override
  Future<void> saveUserProfile(UserProfile userProfile) async {
    await _userProfileBox.put(_userProfileKey, userProfile);
  }
}
