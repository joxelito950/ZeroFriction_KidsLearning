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
    this.keepStars = false,
  });

  final bool loaded;
  final GameDifficulty difficulty;
  final bool timerDisabled;

  /// «Jugar sin tiempo» solo lo cambia un adulto con Premium (R4).
  final bool isPremium;

  /// «Mantener las estrellas» (HU-016): gratuito.
  final bool keepStars;

  GameSettingsState copyWith({GameDifficulty? difficulty, bool? timerDisabled, bool? keepStars}) =>
      GameSettingsState(
        loaded: loaded,
        difficulty: difficulty ?? this.difficulty,
        timerDisabled: timerDisabled ?? this.timerDisabled,
        isPremium: isPremium,
        keepStars: keepStars ?? this.keepStars,
      );

  @override
  bool operator ==(Object other) =>
      other is GameSettingsState &&
      other.loaded == loaded &&
      other.difficulty == difficulty &&
      other.timerDisabled == timerDisabled &&
      other.isPremium == isPremium &&
      other.keepStars == keepStars;

  @override
  int get hashCode => Object.hash(loaded, difficulty, timerDisabled, isPremium, keepStars);
}

/// Lee y cambia la dificultad y «Jugar sin tiempo». Los cambios se guardan al
/// instante; los juegos los aplican en el siguiente tablero (R6).
class GameSettingsCubit extends Cubit<GameSettingsState> {
  GameSettingsCubit({required IPersistenceRepository repository, DateTime Function()? now})
      : _repository = repository,
        _now = now ?? DateTime.now,
        super(const GameSettingsState());

  final IPersistenceRepository _repository;
  final DateTime Function() _now;

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
        keepStars: settings.keepStars,
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

  /// Activarlo congela las estrellas; desactivarlo reinicia la gracia de 7 días
  /// desde ahora (HU-016 R2, R3). Gratuito (R6).
  Future<void> setKeepStars(bool keep) async {
    if (keep == state.keepStars) return;
    emit(state.copyWith(keepStars: keep));
    final DateTime now = _now();
    await _save((current) => current.withKeepStars(keep, at: now));
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
