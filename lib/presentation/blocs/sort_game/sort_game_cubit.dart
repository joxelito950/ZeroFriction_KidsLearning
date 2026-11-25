import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/places/place_drop.dart';
import '../../../domain/progress/game_progress.dart';
import '../../../domain/progress/round_ladder.dart';
import '../../../domain/progress/star_decay.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import '../../../domain/settings/access_policy.dart';
import '../../../domain/settings/game_difficulty.dart';
import '../../../domain/shadows/shadow_drop.dart';
import '../../../domain/sorting/sort_board.dart';
import '../../../domain/sorting/sort_catalog.dart';
import '../../../domain/sorting/sort_ladder.dart';
import 'sort_game_state.dart';

/// «Clasificar» (HU-027): tableros por nivel y ronda, encaje por la parte del
/// objeto que cae sobre su cesta, fallos, estrellas, tiempo desde el oro,
/// guardado del progreso y paso automático, como «A su sitio».
class SortGameCubit extends Cubit<SortGameState> {
  SortGameCubit({required IPersistenceRepository repository, Random? random, DateTime Function()? now})
      : _repository = repository,
        _random = random ?? Random(),
        _now = now ?? DateTime.now,
        super(const SortGameState());

  static const Duration tick = Duration(milliseconds: 100);
  static const Duration celebrationDuration = Duration(seconds: 2);
  static const Duration invitationDuration = Duration(milliseconds: 1500);
  static const Duration timeUpDuration = Duration(milliseconds: 2500);

  final IPersistenceRepository _repository;
  final Random _random;
  final DateTime Function() _now;

  /// Premium (o todo gratis durante la prueba cerrada, D-040).
  bool _premium = false;

  static final RoundLadder _ladder = SortLadder.rounds;

  GameProgress _progress = GameProgress.initial();
  RoundPosition _position = GameProgress.initial().position;
  SortRules _rules = const SortRules(round: GameDifficulty.bronze, level: 1);
  Timer? _ticker;
  Timer? _transition;
  bool _paused = false;

  /// Lee el progreso, aplica la pérdida de estrellas (D-037) y reparte el
  /// tablero guardado.
  Future<void> start() async {
    try {
      _progress = await _repository.readGameProgress(GameId.sorting);
      await _settleStars();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    final bool timerDisabled = await _readTimerDisabled();
    if (isClosed) return;
    _deal(_progress.position, timerDisabled: timerDisabled);
  }

  Future<void> _settleStars() async {
    ParentalSettings settings = ParentalSettings.initial;
    try {
      settings = await _repository.readParentalSettings();
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
    _progress = StarDecay.settle(_progress, settings: settings, now: _now());
    await _saveProgress();
  }

  /// «Jugar sin tiempo» solo cuenta con Premium (HU-030 R11).
  Future<bool> _readTimerDisabled() async {
    try {
      final ParentalSettings settings = await _repository.readParentalSettings();
      final bool premium =
          AccessPolicy.hasPremium(purchased: (await _repository.readUserProfile())?.isPremium ?? false);
      _premium = premium;
      return settings.timerDisabled && premium;
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
      return false;
    }
  }

  /// El niño toca un objeto de la bandeja: arranca el cronómetro.
  void grab(String id) {
    if (state.canDrag(id)) _startTimerIfNeeded();
  }

  /// Suelta el objeto [id] en [box]. [basketBoxes] son las cajas en pantalla
  /// de las cestas. Devuelve qué pasó para que la pantalla lo anime.
  ShadowDropOutcome drop(String id, {required ShadowBox box, required Map<SortColor, ShadowBox> basketBoxes}) {
    final SortBoard? board = state.board;
    if (board == null || !state.canDrag(id)) return ShadowDropOutcome.missed;
    _startTimerIfNeeded();
    final SortPiece piece = board.pieceById(id);
    final ShadowDropOutcome outcome = PlaceDrop.evaluate<SortColor>(
      target: board.targetOf(piece),
      piece: box,
      targets: basketBoxes,
      threshold: state.coverageToSnap,
    );
    _apply(id, outcome);
    return outcome;
  }

  /// Tocando (o con el lector de pantalla): se eligió [id] y después [basket].
  ShadowDropOutcome match(String id, SortColor basket) {
    final SortBoard? board = state.board;
    if (board == null || !state.canDrag(id) || !board.baskets.contains(basket)) return ShadowDropOutcome.missed;
    _startTimerIfNeeded();
    final ShadowDropOutcome outcome =
        board.accepts(basket, board.pieceById(id)) ? ShadowDropOutcome.snapped : ShadowDropOutcome.wrongShadow;
    _apply(id, outcome);
    return outcome;
  }

  /// Un acierto o un fallo es un movimiento; soltar fuera de las cestas, no
  /// (HU-039 R7).
  void _apply(String id, ShadowDropOutcome outcome) {
    switch (outcome) {
      case ShadowDropOutcome.snapped:
        final Set<String> placed = {...state.placed, id};
        emit(state.copyWith(placed: placed, moves: state.moves + 1));
        if (state.pieces.every((piece) => placed.contains(piece.id))) _win();
      case ShadowDropOutcome.wrongShadow:
        emit(state.copyWith(fails: state.fails + 1, moves: state.moves + 1));
      case ShadowDropOutcome.missed:
        break;
    }
  }

  void pause() => _paused = true;

  void resume() => _paused = false;

  void _deal(RoundPosition saved, {required bool timerDisabled}) {
    _stopTimer();
    // Sin Premium, del oro en adelante se juega la plata; lo ganado se conserva.
    final GameDifficulty round = SortLadder.playableRound(saved.round, premium: _premium);
    final bool downgraded = round != saved.round;
    final int level = downgraded ? RoundLadder.firstTimedLevel : saved.level.clamp(1, SortLadder.maxLevel);
    _rules = SortRules(round: round, level: level, timerDisabled: timerDisabled);
    _position = RoundPosition(
      round: round,
      level: level,
      timeLimit: _ladder.limitFor(round, level, timed: _rules.timed),
      tutorialFalls: downgraded ? 0 : saved.tutorialFalls,
    );
    emit(SortGameState(
      phase: SortPhase.playing,
      round: state.round + 1,
      level: level,
      timeLimit: _position.timeLimit,
      board: SortBoard.pick(_random, SortLadder.levelAt(level), _rules),
      basketsFirst: !_rules.randomLayout || _random.nextBool(),
      coverageToSnap: _rules.coverageToSnap,
      gameRound: round,
    ));
  }

  void _startTimerIfNeeded() {
    if (state.timeLimit == null || state.timerStarted) return;
    emit(state.copyWith(timerStarted: true));
    _ticker = Timer.periodic(tick, (_) => _onTick());
  }

  void _onTick() {
    if (_paused || state.phase != SortPhase.playing) return;
    final Duration elapsed = state.elapsed + tick;
    if (elapsed >= state.timeLimit!) {
      _timeUp();
    } else {
      emit(state.copyWith(elapsed: elapsed));
    }
  }

  void _win() {
    _stopTimer();
    final RoundPosition won = _position;
    // El tutorial no da estrellas (HU-037 P2).
    final int stars =
        won.isTutorial ? 0 : SortStars.forWin(objects: SortLadder.levelAt(won.level).objects, fails: state.fails);
    final RoundStep step = _ladder.afterWin(won, timed: _rules.timed);
    _progress = _progress.recordWin(won: won, stars: stars, step: step, at: _now());
    unawaited(_saveProgress());
    if (step.fromTutorial) {
      emit(state.copyWith(phase: SortPhase.inviting));
      _scheduleNext(invitationDuration, step.next);
      return;
    }
    emit(state.copyWith(phase: SortPhase.celebrating, stars: stars, medal: step.medal));
    _scheduleNext(celebrationDuration, step.next);
  }

  void _timeUp() {
    _stopTimer();
    final RoundStep step = _ladder.afterLoss(_position, timed: _rules.timed);
    _progress = _progress.recordLoss(lost: _position, step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: SortPhase.timeUp,
      elapsed: state.timeLimit,
      lossKind: step.droppedRound
          ? SortLoss.easierRound
          : step.retry
              ? SortLoss.restart
              : SortLoss.fewerObjects,
    ));
    _scheduleNext(timeUpDuration, step.next);
  }

  /// Antes del tablero siguiente se vuelve a leer «Jugar sin tiempo».
  void _scheduleNext(Duration delay, RoundPosition next) {
    _transition?.cancel();
    _transition = Timer(delay, () async {
      if (isClosed) return;
      final bool timerDisabled = await _readTimerDisabled();
      if (isClosed) return;
      _deal(next, timerDisabled: timerDisabled);
    });
  }

  Future<void> _saveProgress() async {
    try {
      await _repository.saveGameProgress(GameId.sorting, _progress);
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  void _stopTimer() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    _transition?.cancel();
    return super.close();
  }
}
