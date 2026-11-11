import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/progress/game_progress.dart';
import '../../../domain/progress/round_ladder.dart';
import '../../../domain/progress/star_decay.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import '../../../domain/settings/game_difficulty.dart';
import '../../../domain/shadows/shadow_drop.dart';
import '../../../domain/shadows/shadow_ladder.dart';
import '../../../domain/shadows/shadow_themes.dart';
import 'shadow_game_state.dart';

/// Juego Sombras (HU-007): tableros por nivel, colocación por cobertura, fallos,
/// estrellas, tiempo con Premium, guardado del progreso y paso automático.
class ShadowGameCubit extends Cubit<ShadowGameState> {
  ShadowGameCubit({
    required IPersistenceRepository repository,
    Random? random,
    DateTime Function()? now,
  })  : _repository = repository,
        _random = random ?? Random(),
        _now = now ?? DateTime.now,
        super(const ShadowGameState());

  /// Paso del cronómetro (la barra se actualiza 10 veces por segundo).
  static const Duration tick = Duration(milliseconds: 100);

  /// Celebración tras completar un tablero (R8), como en la memoria.
  static const Duration celebrationDuration = Duration(seconds: 2);

  /// Invitación a jugar tras el tutorial (HU-037 R9).
  static const Duration invitationDuration = Duration(milliseconds: 1500);

  /// Aviso de «se acabó el tiempo», como en la memoria.
  static const Duration timeUpDuration = Duration(milliseconds: 2500);

  final IPersistenceRepository _repository;
  final Random _random;
  final DateTime Function() _now;

  static final RoundLadder _ladder = ShadowLadder.rounds;

  GameProgress _progress = GameProgress.initial();

  /// Posición del tablero en juego, con su ronda y sus caídas al tutorial.
  RoundPosition _position = GameProgress.initial().position;

  /// Reglas del tablero en juego: la dificultad es la ronda (HU-037); Premium
  /// y «Jugar sin tiempo» se vuelven a leer antes de cada tablero (R12).
  ShadowRules _rules = const ShadowRules();
  Timer? _ticker;
  Timer? _transition;
  bool _paused = false;

  /// Lee el progreso, aplica la pérdida de estrellas (D-037) y reparte el
  /// tablero del nivel guardado con su límite de llegada.
  Future<void> start() async {
    try {
      _progress = await _repository.readGameProgress(GameId.shadows);
      await _settleStars();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    final ShadowRules access = await _readRules();
    if (isClosed) return;
    final RoundPosition saved = _progress.position;
    // Sin Premium, el nivel 8 no existe: se juega el 7 (HU-037 P16).
    final int level = saved.level.clamp(1, ShadowLadder.lastLevelFor(premium: access.premium));
    _rules = _rulesFor(saved.round, access);
    _deal(RoundPosition(
      round: saved.round,
      level: level,
      timeLimit: _ladder.limitFor(saved.round, level, timed: _timed(access)),
      tutorialFalls: saved.tutorialFalls,
    ));
  }

  /// Como en la memoria: abrir el juego cuenta como jugar, y la pérdida
  /// acumulada se aplica ahora, salvo con «Mantener las estrellas» (HU-016).
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

  /// Premium y «Jugar sin tiempo». Sin Premium, «Jugar sin tiempo» vuelve a su
  /// valor por defecto y se guarda así (HU-030 R11). Si no se pueden leer,
  /// gratis y con tiempo. La dificultad la pone la ronda ([_rulesFor]).
  Future<ShadowRules> _readRules() async {
    try {
      final ParentalSettings settings = await _repository.readParentalSettings();
      final bool premium = (await _repository.readUserProfile())?.isPremium ?? false;
      if (settings.timerDisabled && !premium) {
        await _repository.updateParentalSettings((current) => current.withTimerDisabled(false));
      }
      return ShadowRules(
        difficulty: settings.difficulty,
        premium: premium,
        timerDisabled: settings.timerDisabled && premium,
      );
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
      return const ShadowRules();
    }
  }

  ShadowRules _rulesFor(GameDifficulty round, ShadowRules access) =>
      ShadowRules(difficulty: round, premium: access.premium, timerDisabled: access.timerDisabled);

  /// Con las rondas hay tiempo también sin Premium; quitarlo («Jugar sin
  /// tiempo») sí es de Premium (HU-037 sección 11.3).
  static bool _timed(ShadowRules rules) => !(rules.premium && rules.timerDisabled);

  /// Termina la animación de inicio (R19): empieza el juego. La pantalla la
  /// llama al acabar la animación, o enseguida con «reducir movimiento».
  void finishIntro() {
    if (state.phase != ShadowRoundPhase.introducing) return;
    emit(state.copyWith(phase: ShadowRoundPhase.playing));
  }

  /// El niño toca un objeto de la bandeja: arranca el cronómetro (R7).
  void grab(String symbol) {
    if (!state.canDrag(symbol)) return;
    _startTimerIfNeeded();
  }

  /// Suelta [symbol] en [object]. [shadowBoxes] son las cajas en pantalla de
  /// las sombras, por su emoji; las ya ocupadas no cuentan. Devuelve qué pasó
  /// para que la pantalla lo anime (R4, R5).
  ShadowDropOutcome drop(String symbol, {required ShadowBox object, required Map<String, ShadowBox> shadowBoxes}) {
    if (!state.canDrag(symbol)) return ShadowDropOutcome.missed;
    _startTimerIfNeeded();
    final ShadowDropOutcome outcome = ShadowDrop.evaluate(
      symbol: symbol,
      object: object,
      shadows: {
        for (final entry in shadowBoxes.entries)
          if (!state.placed.contains(entry.key)) entry.key: entry.value,
      },
      threshold: _rules.coverageToSnap,
    );
    _apply(symbol, outcome);
    return outcome;
  }

  /// Empareja sin arrastrar (R16, lector de pantalla): se eligió [symbol] y
  /// después la sombra [shadow].
  ShadowDropOutcome match(String symbol, String shadow) {
    if (!state.canDrag(symbol) || !state.shadows.contains(shadow) || state.placed.contains(shadow)) {
      return ShadowDropOutcome.missed;
    }
    _startTimerIfNeeded();
    final ShadowDropOutcome outcome = symbol == shadow ? ShadowDropOutcome.snapped : ShadowDropOutcome.wrongShadow;
    _apply(symbol, outcome);
    return outcome;
  }

  void _apply(String symbol, ShadowDropOutcome outcome) {
    switch (outcome) {
      case ShadowDropOutcome.snapped:
        final Set<String> placed = {...state.placed, symbol};
        emit(state.copyWith(placed: placed));
        if (state.objects.every(placed.contains)) _win();
      case ShadowDropOutcome.wrongShadow:
        emit(state.copyWith(fails: state.fails + 1));
      case ShadowDropOutcome.missed:
        break;
    }
  }

  /// La app pasa a segundo plano: el cronómetro se detiene (R7).
  void pause() => _paused = true;

  void resume() => _paused = false;

  void _deal(RoundPosition position) {
    _stopTimer();
    _position = position;
    final ShadowLevel level = ShadowLadder.levelAt(position.level);
    final ShadowBoardContent content = ShadowThemes.pick(_random, level, freeShadows: _rules.freeShadows);
    emit(ShadowGameState(
      phase: _rules.startAnimation ? ShadowRoundPhase.introducing : ShadowRoundPhase.playing,
      round: state.round + 1,
      position: ShadowPosition(level: position.level, timeLimit: position.timeLimit),
      layout: _rules.layoutFor(_random),
      objects: List.of(content.objects)..shuffle(_random),
      shadows: content.shadows,
      premium: _rules.premium,
      hasMedal: _progress.bestMedal != null,
      goldFraction: _progress.goldFraction(_ladder),
      gameRound: position.round,
    ));
  }

  void _startTimerIfNeeded() {
    if (!state.position.isTimed || state.timerStarted) return;
    emit(state.copyWith(timerStarted: true));
    _ticker = Timer.periodic(tick, (_) => _onTick());
  }

  void _onTick() {
    if (_paused || state.phase != ShadowRoundPhase.playing) return;
    final Duration elapsed = state.elapsed + tick;
    if (elapsed >= state.position.timeLimit!) {
      _timeUp();
    } else {
      emit(state.copyWith(elapsed: elapsed));
    }
  }

  void _win() {
    _stopTimer();
    final RoundPosition won = _position;
    // Con las rondas, las 3 estrellas son de todos (HU-037 P16); el tutorial
    // no da ninguna (P2).
    final int stars = won.isTutorial
        ? 0
        : ShadowStars.forWin(objects: ShadowLadder.levelAt(won.level).objects, fails: state.fails, premium: true);
    final RoundStep step = _ladder.afterWin(
      won,
      lastLevel: ShadowLadder.lastLevelFor(premium: _rules.premium),
      timed: _timed(_rules),
    );
    _progress = _progress.recordWin(won: won, stars: stars, step: step, at: _now());
    unawaited(_saveProgress());
    if (step.fromTutorial) {
      emit(state.copyWith(phase: ShadowRoundPhase.inviting));
      _scheduleNextRound(invitationDuration, step.next);
      return;
    }
    emit(state.copyWith(
      phase: ShadowRoundPhase.celebrating,
      stars: stars,
      medalEarned: step.medal != null,
      medal: step.medal,
      hasMedal: _progress.bestMedal != null,
      goldFraction: _progress.goldFraction(_ladder),
    ));
    _scheduleNextRound(celebrationDuration, step.next);
  }

  void _timeUp() {
    _stopTimer();
    final RoundStep step = _ladder.afterLoss(_position, timed: _timed(_rules));
    _progress = _progress.recordLoss(step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: ShadowRoundPhase.timeUp,
      elapsed: state.position.timeLimit,
      lossKind: step.droppedRound
          ? ShadowLoss.easierRound
          : step.next.isTutorial
              ? ShadowLoss.restart
              : ShadowLoss.fewerObjects,
    ));
    _scheduleNextRound(timeUpDuration, step.next);
  }

  /// Antes del tablero siguiente se vuelven a leer las reglas: si cambiaron
  /// (por ejemplo, se compró Premium), se sigue en el mismo nivel con el límite
  /// de llegada de las reglas nuevas (R12, HU-030 R6).
  void _scheduleNextRound(Duration delay, RoundPosition next) {
    _transition?.cancel();
    _transition = Timer(delay, () async {
      if (isClosed) return;
      final ShadowRules access = await _readRules();
      if (isClosed) return;
      // Sin Premium (perdido a mitad), el nivel 8 se juega como el 7.
      final int level = next.level.clamp(1, ShadowLadder.lastLevelFor(premium: access.premium));
      _rules = _rulesFor(next.round, access);
      _deal(RoundPosition(
        round: next.round,
        level: level,
        timeLimit: _ladder.limitFor(next.round, level, timed: _timed(access)),
        tutorialFalls: next.tutorialFalls,
      ));
    });
  }

  /// Un fallo al guardar no interrumpe el juego; se reporta (D-010).
  Future<void> _saveProgress() async {
    try {
      await _repository.saveGameProgress(GameId.shadows, _progress);
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
