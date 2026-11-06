import '../entities/level_state.dart';
import '../entities/memory_progress.dart';
import '../entities/parental_settings.dart';
import '../entities/user_profile.dart';

abstract interface class IPersistenceRepository {
  Future<List<LevelState>> readAllLevelStates();

  Future<LevelState?> readLevelState(String levelId);

  Future<void> saveLevelState(LevelState levelState);

  Future<void> saveLevelStates(Iterable<LevelState> levelStates);

  Future<UserProfile?> readUserProfile();

  Future<void> saveUserProfile(UserProfile userProfile);

  /// Progreso del juego de memoria; [MemoryProgress.initial] si nunca se ha jugado.
  Future<MemoryProgress> readMemoryProgress();

  Future<void> saveMemoryProgress(MemoryProgress progress);

  /// Ajustes de padres y tiempo de hoy (HU-009); [ParentalSettings.initial] si no hay.
  Future<ParentalSettings> readParentalSettings();

  Future<void> saveParentalSettings(ParentalSettings settings);

  /// Lee, cambia y guarda los ajustes de padres de una vez, para que quien
  /// cambia un ajuste no pise los que cambia otro (el tiempo de hoy, HU-009, y
  /// la dificultad, HU-030, se guardan desde sitios distintos).
  Future<ParentalSettings> updateParentalSettings(ParentalSettings Function(ParentalSettings current) update);
}
