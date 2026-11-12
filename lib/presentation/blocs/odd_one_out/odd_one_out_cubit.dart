import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/odd_one_out/odd_one_out.dart';
import '../../../domain/progress/game_progress.dart';
import '../../../domain/progress/round_ladder.dart';
import '../../../domain/progress/star_decay.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import 'odd_one_out_state.dart';
import '../../../domain/settings/access_policy.dart';

/// «¿Cuál es diferente?» (HU-025): 3 tableros por nivel con el tiempo del nivel,
/// fallos y estrellas, rondas y medallas (HU-037), Imposible solo con Premium.
class OddOneOutCubit extends Cubit<OddOneOutState> {
  OddOneOutCubit({required IPersistenceRepository repository, Random? random, DateTime Function()? now})
      : _repository = repository,
        _random = random ?? Random(),
        _now = now ?? DateTime.now,
        super(const OddOneOutState());

  static const Duration tick = Duration(milliseconds: 100);

  /// El diferente salta antes del siguiente tablero (R3).
  static const Duration solvedDuration = Duration(milliseconds: 700);
  static const Duration celebrationDuration = Duration(seconds: 2);
  static const Duration invitationDuration = Duration(milliseconds: 1500);
  static const Duration timeUpDuration = Duration(milliseconds: 2500);

  static final RoundLadder _ladder = OddOneOut.rounds;

  final IPersistenceRepository _repository;
  final Random _random;
  final DateTime Function() _now;

  GameProgress _progress = GameProgress.initial();
  RoundPosition _position = GameProgress.initial().position;
  bool _timed = true;
  bool _premium = false;
  Timer? _ticker;
  Timer? _transition;
  bool _paused = false;

  /// Comparación del tablero anterior y objetos recientes (variedad, 2026-11-12).
  OddKind? _previousKind;
  final List<String> _recent = [];

  /// Cuántos objetos recientes se evitan.
  static const int recentMemory = 6;

  Future<void> start() async {
    try {
      _progress = await _repository.readGameProgress(GameId.oddOneOut);
      ParentalSettings settings = ParentalSettings.initial;
      try {
        settings = await _repository.readParentalSettings();
      } catch (error, stackTrace) {
        if (!isClosed) addError(error, stackTrace);
      }
      _progress = StarDecay.settle(_progress, settings: settings, now: _now());
      await _saveProgress();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    await _readAccess();
    if (isClosed) return;
    _startLevel(_progress.position);
  }

  /// Premium y «Jugar sin tiempo» (solo con Premium; sin él vuelve a su valor
  /// por defecto, HU-030 R11). Si no se pueden leer: gratis y con tiempo.
  Future<void> _readAccess() async {
    try {
      final ParentalSettings settings = await _repository.readParentalSettings();
      _premium = AccessPolicy.hasPremium(purchased: (await _repository.readUserProfile())?.isPremium ?? false);
      if (settings.timerDisabled && !_premium) {
        await _repository.updateParentalSettings((current) => current.withTimerDisabled(false));
      }
      _timed = !(settings.timerDisabled && _premium);
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
      _premium = false;
      _timed = true;
    }
  }

  /// Empieza [next] desde su primer tablero. Sin Premium, la ronda Imposible
  /// se juega como Normal desde su tutorial (P6): el final natural tras la plata.
  void _startLevel(RoundPosition next) {
    final playable = OddOneOut.playableRound(next.round, premium: _premium);
    final RoundPosition position =
        playable == next.round ? next : RoundPosition(round: playable, level: RoundLadder.tutorial);
    // Tras perder se conserva el límite (como HU-001 R5); si no lo trae, o si
    // cambió «Jugar sin tiempo», el de llegada al nivel.
    _position = RoundPosition(
      round: position.round,
      level: position.level,
      timeLimit: _timed ? position.timeLimit ?? _ladder.limitFor(position.round, position.level) : null,
      tutorialFalls: position.tutorialFalls,
    );
    _deal(board: 0, fails: 0, elapsed: Duration.zero, timerStarted: false);
  }

  void _deal({required int board, required int fails, required Duration elapsed, required bool timerStarted}) {
    final OddBoard content = OddOneOut.board(
      _random,
      OddOneOut.levelAt(_position.level),
      _position.round,
      previousKind: _previousKind,
      recent: _recent,
    );
    _previousKind = content.kind;
    // Recuerda los últimos objetos diferentes (y la figura repetida) para que
    // no vuelvan enseguida, en este nivel ni en el siguiente.
    _recent
      ..add(content.odd)
      ..addAll(content.kind == OddKind.identical ? [content.objects[content.oddIndex == 0 ? 1 : 0]] : const []);
    while (_recent.length > recentMemory) {
      _recent.removeAt(0);
    }
    emit(OddOneOutState(
      phase: OddPhase.playing,
      round: state.round + 1,
      gameRound: _position.round,
      level: _position.level,
      timeLimit: _position.timeLimit,
      board: board,
      objects: content.objects,
      oddIndex: content.oddIndex,
      fails: fails,
      elapsed: elapsed,
      timerStarted: timerStarted,
      hasMedal: _progress.bestMedal != null,
      goldFraction: _progress.goldFraction(_ladder),
    ));
  }

  /// Toca un objeto (R3): el diferente salta y sigue el siguiente tablero; otro
  /// hace un «no» y cuenta como fallo.
  void tap(int index) {
    if (state.phase != OddPhase.playing || index < 0 || index >= state.objects.length) return;
    _startTimerIfNeeded();
    if (index != state.oddIndex) {
      emit(state.copyWith(fails: state.fails + 1, wrongIndex: index, wrongCount: state.wrongCount + 1));
      return;
    }
    if (state.board + 1 >= OddOneOut.boardsPerLevel) {
      _win();
      return;
    }
    emit(state.copyWith(phase: OddPhase.solved));
    _transition?.cancel();
    _transition = Timer(solvedDuration, () {
      if (isClosed) return;
      _deal(board: state.board + 1, fails: state.fails, elapsed: state.elapsed, timerStarted: state.timerStarted);
    });
  }

  void pause() => _paused = true;

  void resume() => _paused = false;

  void _startTimerIfNeeded() {
    if (!state.isTimed || _ticker != null) return;
    emit(state.copyWith(timerStarted: true));
    _ticker = Timer.periodic(tick, (_) => _onTick());
  }

  /// El tiempo corre solo con un tablero en juego (no durante el salto).
  void _onTick() {
    if (_paused || state.phase != OddPhase.playing) return;
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
    final int stars = won.isTutorial ? 0 : OddOneOutStars.forWin(fails: state.fails);
    final RoundStep step = _ladder.afterWin(won, timed: _timed);
    _progress = _progress.recordWin(won: won, stars: stars, step: step, at: _now());
    unawaited(_saveProgress());
    if (step.fromTutorial) {
      emit(state.copyWith(phase: OddPhase.inviting));
      _scheduleNext(invitationDuration, step.next);
      return;
    }
    emit(state.copyWith(
      phase: OddPhase.celebrating,
      stars: stars,
      medal: step.medal,
      hasMedal: _progress.bestMedal != null,
      goldFraction: _progress.goldFraction(_ladder),
    ));
    _scheduleNext(celebrationDuration, step.next);
  }

  void _timeUp() {
    _stopTimer();
    final RoundStep step = _ladder.afterLoss(_position, timed: _timed);
    _progress = _progress.recordLoss(step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: OddPhase.timeUp,
      elapsed: state.timeLimit,
      loss: step.droppedRound
          ? OddLoss.easierRound
          : step.next.isTutorial
              ? OddLoss.restart
              : OddLoss.fewerObjects,
    ));
    _scheduleNext(timeUpDuration, step.next);
  }

  /// Antes del nivel siguiente se vuelven a leer Premium y «Jugar sin tiempo».
  void _scheduleNext(Duration delay, RoundPosition next) {
    _transition?.cancel();
    _transition = Timer(delay, () async {
      if (isClosed) return;
      await _readAccess();
      if (isClosed) return;
      _startLevel(next);
    });
  }

  Future<void> _saveProgress() async {
    try {
      await _repository.saveGameProgress(GameId.oddOneOut, _progress);
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
