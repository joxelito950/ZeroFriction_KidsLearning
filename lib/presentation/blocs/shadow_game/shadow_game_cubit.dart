import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/entities/shadow_progress.dart';
import '../../../domain/progress/star_decay.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
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

  /// Aviso de «se acabó el tiempo», como en la memoria.
  static const Duration timeUpDuration = Duration(milliseconds: 2500);

  final IPersistenceRepository _repository;
  final Random _random;
  final DateTime Function() _now;

  ShadowProgress _progress = ShadowProgress.initial;

  /// Reglas con las que se repartió el tablero en juego. Un cambio (dificultad,
  /// «Jugar sin tiempo» o Premium) se aplica en el siguiente tablero (R12).
  ShadowRules _rules = const ShadowRules();
  Timer? _ticker;
  Timer? _transition;
  bool _paused = false;

  /// Lee el progreso, aplica la pérdida de estrellas (D-037) y reparte el
  /// tablero del nivel guardado con su límite de llegada.
  Future<void> start() async {
    try {
      _progress = await _repository.readShadowProgress();
      await _settleStars();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    final ShadowRules rules = await _readRules();
    if (isClosed) return;
    _rules = rules;
    _deal(ShadowLadder.arrivalPosition(_progress.currentLevel, rules));
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

  /// Dificultad, «Jugar sin tiempo» y Premium. Sin Premium, «Jugar sin tiempo»
  /// vuelve a su valor por defecto y se guarda así (HU-030 R11). Si no se
  /// pueden leer, Normal y gratis.
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

  void _deal(ShadowPosition position) {
    _stopTimer();
    final ShadowLevel level = ShadowLadder.levelAt(position.level);
    final ShadowBoardContent content = ShadowThemes.pick(_random, level, freeShadows: _rules.freeShadows);
    emit(ShadowGameState(
      phase: _rules.startAnimation ? ShadowRoundPhase.introducing : ShadowRoundPhase.playing,
      round: state.round + 1,
      position: position,
      layout: _rules.layoutFor(_random),
      objects: List.of(content.objects)..shuffle(_random),
      shadows: content.shadows,
      premium: _rules.premium,
      hasMedal: _progress.hasMedal,
      goldFraction: _progress.goldFraction,
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
    final int level = state.level;
    final int stars = ShadowStars.forWin(
      objects: ShadowLadder.levelAt(level).objects,
      fails: state.fails,
      premium: _rules.premium,
    );
    final ShadowStep step = ShadowLadder.afterWin(state.position, _rules);
    _progress = _progress.recordWin(level: level, stars: stars, step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: ShadowRoundPhase.celebrating,
      stars: stars,
      medalEarned: step.medalEarned,
      hasMedal: _progress.hasMedal,
      goldFraction: _progress.goldFraction,
    ));
    _scheduleNextRound(celebrationDuration, step.next);
  }

  void _timeUp() {
    _stopTimer();
    final ShadowStep step = ShadowLadder.afterLoss(state.position);
    _progress = _progress.recordLoss(step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(phase: ShadowRoundPhase.timeUp, elapsed: state.position.timeLimit));
    _scheduleNextRound(timeUpDuration, step.next);
  }

  /// Antes del tablero siguiente se vuelven a leer las reglas: si cambiaron
  /// (por ejemplo, se compró Premium), se sigue en el mismo nivel con el límite
  /// de llegada de las reglas nuevas (R12, HU-030 R6).
  void _scheduleNextRound(Duration delay, ShadowPosition next) {
    _transition?.cancel();
    _transition = Timer(delay, () async {
      if (isClosed) return;
      final ShadowRules rules = await _readRules();
      if (isClosed) return;
      final ShadowPosition position = rules == _rules ? next : ShadowLadder.arrivalPosition(next.level, rules);
      _rules = rules;
      _deal(position);
    });
  }

  /// Un fallo al guardar no interrumpe el juego; se reporta (D-010).
  Future<void> _saveProgress() async {
    try {
      await _repository.saveShadowProgress(_progress);
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
