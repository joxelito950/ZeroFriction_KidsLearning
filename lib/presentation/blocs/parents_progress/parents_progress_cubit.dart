import 'package:bloc/bloc.dart';

import '../../../domain/entities/user_profile.dart';
import '../../../domain/news/discovery.dart';
import '../../../domain/progress/game_progress.dart';
import '../../../domain/repositories/i_persistence_repository.dart';

/// El progreso de cada juego para «Su progreso» (HU-034). Solo lee, salvo
/// «Ahora no» de la sugerencia (§4.5, R1).
final class ParentsProgressState {
  ParentsProgressState({this.loaded = false, Map<GameId, GameProgress> progress = const {}, this.isNew = false})
      : progress = Map.unmodifiable(progress);

  final bool loaded;
  final Map<GameId, GameProgress> progress;

  /// El adulto aún no ha abierto «Su progreso»: la fila lleva «Nuevo» (HU-041 R7).
  final bool isNew;

  /// Hay una sugerencia: la fila «Su progreso» lleva un punto (P8).
  bool get hasSuggestion => progress.values.any((game) => game.isStuck);

  @override
  bool operator ==(Object other) =>
      other is ParentsProgressState &&
      other.loaded == loaded &&
      other.isNew == isNew &&
      other.progress.length == progress.length &&
      progress.entries.every((entry) => other.progress[entry.key] == entry.value);

  @override
  int get hashCode =>
      Object.hash(loaded, isNew, Object.hashAllUnordered(progress.entries.map((e) => Object.hash(e.key, e.value))));
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
      final bool isNew = await _isNew();
      if (!isClosed) emit(ParentsProgressState(loaded: true, progress: progress, isNew: isNew));
    } catch (error, stackTrace) {
      if (isClosed) return;
      addError(error, stackTrace);
      emit(ParentsProgressState(loaded: true, progress: state.progress, isNew: state.isNew));
    }
  }

  Future<bool> _isNew() async {
    try {
      return (await _repository.readUserProfile())?.discovered.isNewFeature(ParentsFeature.progress) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// El adulto abrió «Su progreso»: deja de ser nuevo (HU-041 R7).
  Future<void> markSeen() async {
    if (!state.isNew) return;
    emit(ParentsProgressState(loaded: state.loaded, progress: state.progress));
    try {
      final UserProfile profile =
          await _repository.readUserProfile() ?? const UserProfile(isPremium: false, isSoundEnabled: true);
      await _repository.saveUserProfile(
          profile.copyWith(discovery: profile.discovered.sawFeature(ParentsFeature.progress)));
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  /// «Ahora no» (§4.5): la sugerencia de [game] se oculta hasta que vuelva a
  /// cumplirse la condición desde cero.
  Future<void> dismiss(GameId game) async {
    try {
      final GameProgress progress = (await _repository.readGameProgress(game)).withoutStuck();
      await _repository.saveGameProgress(game, progress);
      if (!isClosed) {
        emit(ParentsProgressState(loaded: true, progress: {...state.progress, game: progress}, isNew: state.isNew));
      }
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }
}
