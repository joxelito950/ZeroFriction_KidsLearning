import 'package:hive_ce/hive.dart';

import '../../domain/entities/level_state.dart';
import '../../domain/entities/parental_settings.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/parental/play_history.dart';
import '../../domain/progress/game_progress.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import 'models/game_progress_hive_model.dart';
import 'models/level_state_hive_model.dart';
import 'models/memory_progress_hive_model.dart';
import 'models/parental_settings_hive_model.dart';
import 'models/play_day_hive_model.dart';
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
    required Box<GameProgressHiveModel> gameProgressBox,
    required Box<PlayDayHiveModel> playHistoryBox,
  })  : _levelStateBox = levelStateBox,
        _userProfileBox = userProfileBox,
        _memoryProgressBox = memoryProgressBox,
        _parentalSettingsBox = parentalSettingsBox,
        _shadowProgressBox = shadowProgressBox,
        _gameProgressBox = gameProgressBox,
        _playHistoryBox = playHistoryBox;

  final Box<LevelStateHiveModel> _levelStateBox;
  final Box<UserProfileHiveModel> _userProfileBox;
  final Box<MemoryProgressHiveModel> _memoryProgressBox;
  final Box<ParentalSettingsHiveModel> _parentalSettingsBox;
  final Box<ShadowProgressHiveModel> _shadowProgressBox;

  /// Progreso común de los juegos que nacen con las rondas, por su `GameId`.
  final Box<GameProgressHiveModel> _gameProgressBox;

  /// Historial de juego (HU-034 R3): un día por clave `aaaa-mm-dd`.
  final Box<PlayDayHiveModel> _playHistoryBox;

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
          GameId.oddOneOut => _gameProgressBox.get(game.name)?.toGameProgress(),
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
      case GameId.oddOneOut:
        await _gameProgressBox.put(game.name, GameProgressHiveModel.fromGameProgress(progress));
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

  /// Borra de la caja los días que ya salen de la ventana (R3): el historial
  /// no crece aunque la app se use durante años.
  @override
  Future<PlayHistory> readPlayHistory(DateTime now) async {
    final PlayHistory saved = PlayHistory(_playHistoryBox.values.map((model) => model.toPlayDay()));
    final PlayHistory kept = saved.keptOn(now);
    final Set<DateTime> keptDays = {for (final PlayDay day in kept.days) day.day};
    final List<dynamic> expired = [
      for (final dynamic key in _playHistoryBox.keys)
        if (_playHistoryBox.get(key) case final PlayDayHiveModel model
            when !keptDays.contains(model.toPlayDay().day))
          key,
    ];
    if (expired.isNotEmpty) await _playHistoryBox.deleteAll(expired);
    return kept;
  }

  @override
  Future<void> savePlayDay(PlayDay day) =>
      _playHistoryBox.put(PlayDayHiveModel.keyOf(day.day), PlayDayHiveModel.fromPlayDay(day));

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
