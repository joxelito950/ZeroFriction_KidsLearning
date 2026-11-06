import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import '../../../domain/settings/game_difficulty.dart';

/// Ajustes de la sección «Juegos» de la Zona de Padres (HU-030).
final class GameSettingsState {
  const GameSettingsState({
    this.loaded = false,
    this.difficulty = GameDifficulty.normal,
    this.timerDisabled = false,
    this.isPremium = false,
  });

  final bool loaded;
  final GameDifficulty difficulty;
  final bool timerDisabled;

  /// «Jugar sin tiempo» solo lo cambia un adulto con Premium (R4).
  final bool isPremium;

  GameSettingsState copyWith({GameDifficulty? difficulty, bool? timerDisabled}) => GameSettingsState(
        loaded: loaded,
        difficulty: difficulty ?? this.difficulty,
        timerDisabled: timerDisabled ?? this.timerDisabled,
        isPremium: isPremium,
      );

  @override
  bool operator ==(Object other) =>
      other is GameSettingsState &&
      other.loaded == loaded &&
      other.difficulty == difficulty &&
      other.timerDisabled == timerDisabled &&
      other.isPremium == isPremium;

  @override
  int get hashCode => Object.hash(loaded, difficulty, timerDisabled, isPremium);
}

/// Lee y cambia la dificultad y «Jugar sin tiempo». Los cambios se guardan al
/// instante; los juegos los aplican en el siguiente tablero (R6).
class GameSettingsCubit extends Cubit<GameSettingsState> {
  GameSettingsCubit({required IPersistenceRepository repository})
      : _repository = repository,
        super(const GameSettingsState());

  final IPersistenceRepository _repository;

  Future<void> load() async {
    try {
      ParentalSettings settings = await _repository.readParentalSettings();
      final bool premium = (await _repository.readUserProfile())?.isPremium ?? false;
      // Sin Premium, «Jugar sin tiempo» vuelve a su valor por defecto (R11).
      if (settings.timerDisabled && !premium) {
        settings = await _repository.updateParentalSettings((current) => current.withTimerDisabled(false));
      }
      if (isClosed) return;
      emit(GameSettingsState(
        loaded: true,
        difficulty: settings.difficulty,
        timerDisabled: settings.timerDisabled,
        isPremium: premium,
      ));
    } catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(const GameSettingsState(loaded: true));
    }
  }

  Future<void> setDifficulty(GameDifficulty difficulty) async {
    if (difficulty == state.difficulty) return;
    emit(state.copyWith(difficulty: difficulty));
    await _save((current) => current.withDifficulty(difficulty));
  }

  /// Sin Premium no hace nada (R4).
  Future<void> setTimerDisabled(bool disabled) async {
    if (!state.isPremium || disabled == state.timerDisabled) return;
    emit(state.copyWith(timerDisabled: disabled));
    await _save((current) => current.withTimerDisabled(disabled));
  }

  /// Un fallo al guardar no rompe la pantalla; se reporta (D-010).
  Future<void> _save(ParentalSettings Function(ParentalSettings) change) async {
    try {
      await _repository.updateParentalSettings(change);
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }
}
