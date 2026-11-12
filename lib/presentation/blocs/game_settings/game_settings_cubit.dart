import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/progress/game_progress.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import '../../../domain/settings/game_difficulty.dart';
import '../../../domain/settings/access_policy.dart';

/// Ajustes de la sección «Juegos» de la Zona de Padres (HU-030), con la ronda
/// de cada juego (HU-037 P1) en lugar de la dificultad general.
final class GameSettingsState {
  const GameSettingsState({
    this.loaded = false,
    this.rounds = const {
      GameId.memory: GameDifficulty.easy,
      GameId.shadows: GameDifficulty.easy,
      GameId.oddOneOut: GameDifficulty.easy,
    },
    this.timerDisabled = false,
    this.isPremium = false,
    this.keepStars = false,
  });

  final bool loaded;

  /// Ronda en la que va cada juego.
  final Map<GameId, GameDifficulty> rounds;
  final bool timerDisabled;

  /// «Jugar sin tiempo» solo lo cambia un adulto con Premium (R4).
  final bool isPremium;

  /// «Mantener las estrellas» (HU-016): gratuito.
  final bool keepStars;

  GameSettingsState copyWith({Map<GameId, GameDifficulty>? rounds, bool? timerDisabled, bool? keepStars}) =>
      GameSettingsState(
        loaded: loaded,
        rounds: rounds ?? this.rounds,
        timerDisabled: timerDisabled ?? this.timerDisabled,
        isPremium: isPremium,
        keepStars: keepStars ?? this.keepStars,
      );

  @override
  bool operator ==(Object other) =>
      other is GameSettingsState &&
      other.loaded == loaded &&
      other.rounds.length == rounds.length &&
      rounds.entries.every((entry) => other.rounds[entry.key] == entry.value) &&
      other.timerDisabled == timerDisabled &&
      other.isPremium == isPremium &&
      other.keepStars == keepStars;

  @override
  int get hashCode => Object.hash(
      loaded,
      Object.hashAllUnordered(rounds.entries.map((e) => Object.hash(e.key, e.value))),
      timerDisabled,
      isPremium,
      keepStars);
}

/// Lee y cambia la ronda de cada juego, «Jugar sin tiempo» y «Mantener las
/// estrellas». Los cambios se guardan al instante.
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
      final bool premium =
          AccessPolicy.hasPremium(purchased: (await _repository.readUserProfile())?.isPremium ?? false);
      // Sin Premium, «Jugar sin tiempo» vuelve a su valor por defecto (R11).
      if (settings.timerDisabled && !premium) {
        settings = await _repository.updateParentalSettings((current) => current.withTimerDisabled(false));
      }
      final Map<GameId, GameDifficulty> rounds = {
        for (final GameId game in GameId.values) game: (await _repository.readGameProgress(game)).position.round,
      };
      if (isClosed) return;
      emit(GameSettingsState(
        loaded: true,
        rounds: rounds,
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

  /// El adulto cambia la ronda de [game] (HU-037 P1): se empieza por su
  /// tutorial, sin perder estrellas ni medallas (R5).
  Future<void> setRound(GameId game, GameDifficulty round) async {
    if (round == state.rounds[game]) return;
    emit(state.copyWith(rounds: {...state.rounds, game: round}));
    try {
      final GameProgress progress = await _repository.readGameProgress(game);
      await _repository.saveGameProgress(game, progress.withRound(round));
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
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
