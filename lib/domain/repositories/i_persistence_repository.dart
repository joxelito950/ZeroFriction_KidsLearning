import '../entities/level_state.dart';
import '../entities/user_profile.dart';

abstract interface class IPersistenceRepository {
  Future<List<LevelState>> readAllLevelStates();

  Future<LevelState?> readLevelState(String levelId);

  Future<void> saveLevelState(LevelState levelState);

  Future<void> saveLevelStates(Iterable<LevelState> levelStates);

  Future<UserProfile?> readUserProfile();

  Future<void> saveUserProfile(UserProfile userProfile);
}
