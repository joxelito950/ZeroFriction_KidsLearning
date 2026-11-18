import 'package:bloc/bloc.dart';

import '../../../domain/progress/game_progress.dart';
import '../../../domain/repositories/i_persistence_repository.dart';

/// El progreso de cada juego para «Su progreso» (HU-034). Solo lee, salvo
/// «Ahora no» de la sugerencia (§4.5, R1).
final class ParentsProgressState {
  ParentsProgressState({this.loaded = false, Map<GameId, GameProgress> progress = const {}})
      : progress = Map.unmodifiable(progress);

  final bool loaded;
  final Map<GameId, GameProgress> progress;

  /// Hay una sugerencia: la fila «Su progreso» lleva un punto (P8).
  bool get hasSuggestion => progress.values.any((game) => game.isStuck);

  @override
  bool operator ==(Object other) =>
      other is ParentsProgressState &&
      other.loaded == loaded &&
      other.progress.length == progress.length &&
      progress.entries.every((entry) => other.progress[entry.key] == entry.value);

  @override
  int get hashCode =>
      Object.hash(loaded, Object.hashAllUnordered(progress.entries.map((e) => Object.hash(e.key, e.value))));
}

class ParentsProgressCubit extends Cubit<ParentsProgressState> {
  ParentsProgressCubit({required IPersistenceRepository repository})
      : _repository = repository,
        super(ParentsProgressState());

  final IPersistenceRepository _repository;

  Future<void> load() async {
    try {
      final Map<GameId, GameProgress> progress = {
        for (final GameId game in GameId.values) game: await _repository.readGameProgress(game),
      };
      if (!isClosed) emit(ParentsProgressState(loaded: true, progress: progress));
    } catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(ParentsProgressState(loaded: true, progress: state.progress));
    }
  }

  /// «Ahora no» (§4.5): la sugerencia de [game] se oculta hasta que vuelva a
  /// cumplirse la condición desde cero.
  Future<void> dismiss(GameId game) async {
    try {
      final GameProgress progress = (await _repository.readGameProgress(game)).withoutStuck();
      await _repository.saveGameProgress(game, progress);
      if (!isClosed) emit(ParentsProgressState(loaded: true, progress: {...state.progress, game: progress}));
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }
}
