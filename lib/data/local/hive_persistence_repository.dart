import 'package:hive_ce/hive.dart';

import '../../domain/entities/level_state.dart';
import '../../domain/entities/parental_settings.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/progress/game_progress.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import 'models/level_state_hive_model.dart';
import 'models/memory_progress_hive_model.dart';
import 'models/parental_settings_hive_model.dart';
import 'models/shadow_progress_hive_model.dart';
import 'models/user_profile_hive_model.dart';

/// Implementa el contrato de dominio sobre Hive. Guarda modelos de persistencia
/// y entrega entidades de dominio: el resto de la app nunca ve tipos de Hive.
class HivePersistenceRepository implements IPersistenceRepository {
  static const String _userProfileKey = 'current_user_profile';
  static const String _memoryProgressKey = 'current_memory_progress';
  static const String _parentalSettingsKey = 'current_parental_settings';
  static const String _shadowProgressKey = 'current_shadow_progress';

  const HivePersistenceRepository({
    required Box<LevelStateHiveModel> levelStateBox,
    required Box<UserProfileHiveModel> userProfileBox,
    required Box<MemoryProgressHiveModel> memoryProgressBox,
    required Box<ParentalSettingsHiveModel> parentalSettingsBox,
    required Box<ShadowProgressHiveModel> shadowProgressBox,
  })  : _levelStateBox = levelStateBox,
        _userProfileBox = userProfileBox,
        _memoryProgressBox = memoryProgressBox,
        _parentalSettingsBox = parentalSettingsBox,
        _shadowProgressBox = shadowProgressBox;

  final Box<LevelStateHiveModel> _levelStateBox;
  final Box<UserProfileHiveModel> _userProfileBox;
  final Box<MemoryProgressHiveModel> _memoryProgressBox;
  final Box<ParentalSettingsHiveModel> _parentalSettingsBox;
  final Box<ShadowProgressHiveModel> _shadowProgressBox;

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
  Future<GameProgress> readGameProgress(GameId game) async {
    return switch (game) {
          GameId.memory => _memoryProgressBox.get(_memoryProgressKey)?.toGameProgress(),
          GameId.shadows => _shadowProgressBox.get(_shadowProgressKey)?.toGameProgress(),
        } ??
        GameProgress.initial();
  }

  @override
  Future<void> saveGameProgress(GameId game, GameProgress progress) async {
    switch (game) {
      case GameId.memory:
        await _memoryProgressBox.put(_memoryProgressKey, MemoryProgressHiveModel.fromGameProgress(progress));
      case GameId.shadows:
        await _shadowProgressBox.put(_shadowProgressKey, ShadowProgressHiveModel.fromGameProgress(progress));
    }
  }

  @override
  Future<ParentalSettings> readParentalSettings() async {
    return _parentalSettingsBox.get(_parentalSettingsKey)?.toEntity() ?? ParentalSettings.initial;
  }

  @override
  Future<void> saveParentalSettings(ParentalSettings settings) async {
    await _parentalSettingsBox.put(_parentalSettingsKey, ParentalSettingsHiveModel.fromEntity(settings));
  }

  /// La lectura y la escritura en memoria de Hive ocurren sin ningún `await` en
  /// medio: ninguna otra actualización se puede colar entre las dos.
  @override
  Future<ParentalSettings> updateParentalSettings(ParentalSettings Function(ParentalSettings current) update) async {
    final ParentalSettings current =
        _parentalSettingsBox.get(_parentalSettingsKey)?.toEntity() ?? ParentalSettings.initial;
    final ParentalSettings next = update(current);
    await _parentalSettingsBox.put(_parentalSettingsKey, ParentalSettingsHiveModel.fromEntity(next));
    return next;
  }
}
