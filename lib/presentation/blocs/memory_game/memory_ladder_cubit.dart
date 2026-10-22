import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/memory_progress.dart';
import '../../../domain/memory/memory_ladder.dart';
import '../../../domain/memory/memory_stars.dart';
import '../../../domain/memory/memory_themes.dart';
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
  })  : _repository = repository,
        _random = random ?? Random(),
        _now = now ?? DateTime.now,
        super(const MemoryLadderState());

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

  MemoryProgress _progress = MemoryProgress.initial;
  Timer? _ticker;
  Timer? _transition;
  bool _paused = false;

  /// Identifica la ronda en juego; los temporizadores de rondas anteriores se ignoran.
  int _round = 0;

  /// Lee el progreso y reparte el tablero del nivel guardado, con su límite de llegada (R12).
  Future<void> start() async {
    try {
      _progress = await _repository.readMemoryProgress();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    if (isClosed) return;
    _deal(MemoryLadder.arrivalPosition(_progress.currentLevel));
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
    emit(MemoryLadderState(
      phase: MemoryRoundPhase.playing,
      position: position,
      cards: cards,
      hasBadge: _progress.hasBadge,
    ));
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
    final MemoryLadderStep step = MemoryLadder.afterWin(state.position);
    _progress = _progress.recordWin(level: level, stars: stars, step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: MemoryRoundPhase.celebrating,
      stars: stars,
      badgeEarned: step.badgeEarned,
      hasBadge: _progress.hasBadge,
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

  void _scheduleNextRound(Duration delay, MemoryLadderPosition next) {
    _transition?.cancel();
    _transition = Timer(delay, () {
      if (!isClosed) _deal(next);
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
    return super.close();
  }
}
