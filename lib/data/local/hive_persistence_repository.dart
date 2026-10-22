import 'package:hive_ce/hive.dart';

import '../../domain/entities/level_state.dart';
import '../../domain/entities/memory_progress.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import 'models/level_state_hive_model.dart';
import 'models/memory_progress_hive_model.dart';
import 'models/user_profile_hive_model.dart';

/// Implementa el contrato de dominio sobre Hive. Guarda modelos de persistencia
/// y entrega entidades de dominio: el resto de la app nunca ve tipos de Hive.
class HivePersistenceRepository implements IPersistenceRepository {
  static const String _userProfileKey = 'current_user_profile';
  static const String _memoryProgressKey = 'current_memory_progress';

  const HivePersistenceRepository({
    required Box<LevelStateHiveModel> levelStateBox,
    required Box<UserProfileHiveModel> userProfileBox,
    required Box<MemoryProgressHiveModel> memoryProgressBox,
  })  : _levelStateBox = levelStateBox,
        _userProfileBox = userProfileBox,
        _memoryProgressBox = memoryProgressBox;

  final Box<LevelStateHiveModel> _levelStateBox;
  final Box<UserProfileHiveModel> _userProfileBox;
  final Box<MemoryProgressHiveModel> _memoryProgressBox;

  @override
  Future<List<LevelState>> readAllLevelStates() async {
    return _levelStateBox.values
        .map((model) => model.toEntity())
        .toList(growable: false);
  }

  @override
  Future<LevelState?> readLevelState(String levelId) async {
    return _levelStateBox.get(levelId)?.toEntity();
  }

  @override
  Future<void> saveLevelState(LevelState levelState) async {
    await _levelStateBox.put(
      levelState.levelId,
      LevelStateHiveModel.fromEntity(levelState),
    );
  }

  @override
  Future<void> saveLevelStates(Iterable<LevelState> levelStates) async {
    final Map<String, LevelStateHiveModel> levelStateById = {
      for (final levelState in levelStates)
        levelState.levelId: LevelStateHiveModel.fromEntity(levelState),
    };

    await _levelStateBox.putAll(levelStateById);
  }

  @override
  Future<UserProfile?> readUserProfile() async {
    final UserProfileHiveModel? savedProfile = _userProfileBox.get(_userProfileKey) ??
        (_userProfileBox.isNotEmpty ? _userProfileBox.values.first : null);

    return savedProfile?.toEntity() ??
        const UserProfile(
          isPremium: false,
          isSoundEnabled: true,
        );
  }

  @override
  Future<void> saveUserProfile(UserProfile userProfile) async {
    await _userProfileBox.put(
      _userProfileKey,
      UserProfileHiveModel.fromEntity(userProfile),
    );
  }

  @override
  Future<MemoryProgress> readMemoryProgress() async {
    return _memoryProgressBox.get(_memoryProgressKey)?.toEntity() ?? MemoryProgress.initial;
  }

  @override
  Future<void> saveMemoryProgress(MemoryProgress progress) async {
    await _memoryProgressBox.put(_memoryProgressKey, MemoryProgressHiveModel.fromEntity(progress));
  }
}
