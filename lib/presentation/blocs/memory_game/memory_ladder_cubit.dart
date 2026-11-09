import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/memory_progress.dart';
import '../../../domain/entities/parental_settings.dart';
import '../../../domain/memory/memory_ladder.dart';
import '../../../domain/memory/memory_stars.dart';
import '../../../domain/memory/memory_themes.dart';
import '../../../domain/progress/star_decay.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import 'memory_card_model.dart';
import 'memory_ladder_state.dart';

/// Juego de memoria progresivo (HU-001): escalera de niveles, cronómetro,
/// estrellas, guardado del progreso y transiciones automáticas.
class MemoryLadderCubit extends Cubit<MemoryLadderState> {
  MemoryLadderCubit({
    required IPersistenceRepository repository,
    Random? random,
    DateTime Function()? now,
    Duration? preview,
  })  : _repository = repository,
        _random = random ?? Random(),
        _now = now ?? DateTime.now,
        _preview = preview ?? previewDuration,
        super(const MemoryLadderState());

  /// Vista previa de las cartas en Fácil y Normal (HU-030 3.4, P8).
  static const Duration previewDuration = Duration(seconds: 1);

  /// Paso del cronómetro (la barra se actualiza 10 veces por segundo).
  static const Duration tick = Duration(milliseconds: 100);

  /// Tiempo para memorizar dos cartas distintas antes de ocultarlas.
  static const Duration mismatchDelay = Duration(milliseconds: 1200);

  /// Celebración tras ganar (R14).
  static const Duration celebrationDuration = Duration(seconds: 2);

  /// Aviso de «se acabó el tiempo» (R15).
  static const Duration timeUpDuration = Duration(milliseconds: 2500);

  final IPersistenceRepository _repository;
  final Random _random;
  final DateTime Function() _now;
  final Duration _preview;

  MemoryProgress _progress = MemoryProgress.initial;

  /// Reglas con las que se repartió el tablero en juego (HU-030). Un cambio en
  /// la Zona de Padres se aplica en el siguiente tablero (R6).
  MemoryLadderRules _rules = MemoryLadderRules.standard;
  Timer? _ticker;
  Timer? _transition;
  Timer? _previewTimer;
  bool _paused = false;

  /// Identifica la ronda en juego; los temporizadores de rondas anteriores se ignoran.
  int _round = 0;

  /// Lee el progreso y reparte el tablero del nivel guardado, con su límite de llegada (R12).
  Future<void> start() async {
    try {
      _progress = await _repository.readMemoryProgress();
      await _settleStars();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    final MemoryLadderRules rules = await _readRules();
    if (isClosed) return;
    _rules = rules;
    _deal(MemoryLadder.arrivalPosition(_progress.currentLevel, rules));
  }

  /// Al empezar el juego se aplica la pérdida de estrellas acumulada y se guarda
  /// (D-037), salvo con «Mantener las estrellas» (HU-016). Abrir el juego cuenta
  /// como jugar: la pérdida se detiene desde ahora (HU-002 R9, R13). Si no se
  /// pudo leer el progreso, no se llega aquí y no se pisa nada.
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

  /// La dificultad y «Jugar sin tiempo» de la Zona de Padres. Sin tiempo solo
  /// con Premium (HU-030 R4); si se perdió Premium, el ajuste vuelve a su valor
  /// por defecto y se guarda así (R11). Si no se pueden leer, Normal con tiempo.
  Future<MemoryLadderRules> _readRules() async {
    try {
      final ParentalSettings settings = await _repository.readParentalSettings();
      final bool premium = (await _repository.readUserProfile())?.isPremium ?? false;
      if (settings.timerDisabled && !premium) {
        await _repository.updateParentalSettings((current) => current.withTimerDisabled(false));
      }
      return MemoryLadderRules(difficulty: settings.difficulty, timed: !(settings.timerDisabled && premium));
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
      return MemoryLadderRules.standard;
    }
  }

  Future<void> flipCard(int index) async {
    if (state.phase != MemoryRoundPhase.playing || index < 0 || index >= state.cards.length) return;
    final MemoryCard card = state.cards[index];
    if (state.isProcessing || card.isFaceUp || card.isMatched) return;

    _startTimerIfNeeded();
    final cards = List<MemoryCard>.from(state.cards);
    cards[index] = card.copyWith(isFaceUp: true);

    final int? firstIndex = state.firstSelectedCardIndex;
    if (firstIndex == null) {
      emit(state.copyWith(cards: cards, firstSelectedCardIndex: index));
      return;
    }

    final int moves = state.moves + 1;
    if (cards[firstIndex].assetPath == cards[index].assetPath) {
      cards[firstIndex] = cards[firstIndex].copyWith(isMatched: true);
      cards[index] = cards[index].copyWith(isMatched: true);
      emit(state.copyWith(cards: cards, moves: moves, clearSelection: true));
      if (cards.every((card) => card.isMatched)) _win();
      return;
    }

    emit(state.copyWith(cards: cards, moves: moves, isProcessing: true));
    final int round = _round;
    await Future<void>.delayed(mismatchDelay);
    if (isClosed || round != _round || state.phase != MemoryRoundPhase.playing) return;

    final hidden = List<MemoryCard>.from(state.cards);
    hidden[firstIndex] = hidden[firstIndex].copyWith(isFaceUp: false);
    hidden[index] = hidden[index].copyWith(isFaceUp: false);
    emit(state.copyWith(cards: hidden, isProcessing: false, clearSelection: true));
  }

  /// La app pasa a segundo plano: el cronómetro se detiene (R11).
  void pause() => _paused = true;

  /// La app vuelve: el cronómetro sigue desde donde estaba (criterio 11).
  void resume() => _paused = false;

  void _deal(MemoryLadderPosition position) {
    _stopTimer();
    _previewTimer?.cancel();
    _round++;
    final MemoryLevel level = MemoryLadder.levelAt(position.level);
    final MemoryBoardContent content = MemoryThemes.pick(_random, pairs: level.pairs);
    var id = 0;
    final cards = [
      for (final symbol in content.symbols) ...[
        MemoryCard(id: id++, assetPath: symbol),
        MemoryCard(id: id++, assetPath: symbol),
      ],
    ]..shuffle(_random);
    final bool preview = _rules.preview && _preview > Duration.zero;
    emit(MemoryLadderState(
      phase: preview ? MemoryRoundPhase.previewing : MemoryRoundPhase.playing,
      round: _round,
      position: position,
      cards: preview ? [for (final card in cards) card.copyWith(isFaceUp: true)] : cards,
      hasBadge: _progress.hasBadge,
      goldFraction: _progress.goldFraction,
    ));
    if (!preview) return;
    // Pasado el momento, se voltean todas a la vez y empieza el juego (V2).
    final int round = _round;
    _previewTimer = Timer(_preview, () {
      if (isClosed || round != _round) return;
      emit(state.copyWith(
        phase: MemoryRoundPhase.playing,
        cards: [for (final card in state.cards) card.copyWith(isFaceUp: false)],
      ));
    });
  }

  void _startTimerIfNeeded() {
    if (!state.position.isTimed || state.timerStarted) return;
    emit(state.copyWith(timerStarted: true));
    _ticker = Timer.periodic(tick, (_) => _onTick());
  }

  void _onTick() {
    if (_paused || state.phase != MemoryRoundPhase.playing) return;
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
    final int stars = MemoryStars.forWin(level: level, moves: state.moves);
    final MemoryLadderStep step = MemoryLadder.afterWin(state.position, _rules);
    _progress = _progress.recordWin(level: level, stars: stars, step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: MemoryRoundPhase.celebrating,
      stars: stars,
      badgeEarned: step.badgeEarned,
      hasBadge: _progress.hasBadge,
      goldFraction: _progress.goldFraction,
      isProcessing: true,
    ));
    _scheduleNextRound(celebrationDuration, step.next);
  }

  void _timeUp() {
    _stopTimer();
    final MemoryLadderStep step = MemoryLadder.afterLoss(state.position);
    _progress = _progress.recordLoss(step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: MemoryRoundPhase.timeUp,
      elapsed: state.position.timeLimit,
      loss: step.loss,
      isProcessing: true,
    ));
    _scheduleNextRound(timeUpDuration, step.next);
  }

  /// Antes del tablero siguiente se vuelven a leer los ajustes: si cambiaron,
  /// se sigue en el mismo nivel con el límite de llegada de las reglas nuevas
  /// (HU-030 R6).
  void _scheduleNextRound(Duration delay, MemoryLadderPosition next) {
    _transition?.cancel();
    _transition = Timer(delay, () async {
      if (isClosed) return;
      final MemoryLadderRules rules = await _readRules();
      if (isClosed) return;
      final MemoryLadderPosition position = rules == _rules ? next : MemoryLadder.arrivalPosition(next.level, rules);
      _rules = rules;
      _deal(position);
    });
  }

  /// Un fallo al guardar no interrumpe el juego; se reporta (D-010).
  Future<void> _saveProgress() async {
    try {
      await _repository.saveMemoryProgress(_progress);
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
    _previewTimer?.cancel();
    return super.close();
  }
}
