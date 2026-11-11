import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/memory/memory_ladder.dart';
import '../../../domain/memory/memory_stars.dart';
import '../../../domain/memory/memory_themes.dart';
import '../../../domain/progress/game_progress.dart';
import '../../../domain/progress/round_ladder.dart';
import '../../../domain/progress/star_decay.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import 'memory_card_model.dart';
import 'memory_ladder_state.dart';

/// Juego de memoria progresivo (HU-001) con rondas de dificultad (HU-037):
/// tutorial sin tiempo, niveles con el tiempo de la ronda, medallas, bajada de
/// ronda, estrellas, guardado del progreso y transiciones automáticas.
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

  /// Invitación a jugar tras el tutorial (HU-037 R9).
  static const Duration invitationDuration = Duration(milliseconds: 1500);

  /// Aviso de «se acabó el tiempo» (R15).
  static const Duration timeUpDuration = Duration(milliseconds: 2500);

  static final RoundLadder _ladder = MemoryLadder.rounds;

  final IPersistenceRepository _repository;
  final Random _random;
  final DateTime Function() _now;
  final Duration _preview;

  GameProgress _progress = GameProgress.initial();

  /// Posición del tablero en juego, con su ronda y sus caídas al tutorial.
  RoundPosition _position = GameProgress.initial().position;

  /// «Jugar sin tiempo» con Premium (HU-030 R4). Se vuelve a leer antes de
  /// cada tablero: un cambio en la Zona de Padres se aplica en el siguiente.
  bool _timed = true;
  Timer? _ticker;
  Timer? _transition;
  Timer? _previewTimer;
  bool _paused = false;

  /// Identifica la ronda en juego; los temporizadores de rondas anteriores se ignoran.
  int _round = 0;

  /// Lee el progreso y reparte el tablero guardado, con su límite de llegada.
  Future<void> start() async {
    try {
      _progress = await _repository.readGameProgress(GameId.memory);
      await _settleStars();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    _timed = await _readTimed();
    if (isClosed) return;
    final RoundPosition saved = _progress.position;
    _deal(RoundPosition(
      round: saved.round,
      level: saved.level,
      timeLimit: _ladder.limitFor(saved.round, saved.level, timed: _timed),
      tutorialFalls: saved.tutorialFalls,
    ));
  }

  /// Al empezar el juego se aplica la pérdida de estrellas acumulada y se guarda
  /// (D-037), salvo con «Mantener las estrellas» (HU-016). Abrir el juego cuenta
  /// como jugar (HU-002 R9, R13). Si no se pudo leer el progreso, no se llega
  /// aquí y no se pisa nada.
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

  /// «Jugar sin tiempo» solo con Premium (HU-030 R4); si se perdió Premium, el
  /// ajuste vuelve a su valor por defecto y se guarda así (R11). Si no se puede
  /// leer, hay tiempo.
  Future<bool> _readTimed() async {
    try {
      final ParentalSettings settings = await _repository.readParentalSettings();
      final bool premium = (await _repository.readUserProfile())?.isPremium ?? false;
      if (settings.timerDisabled && !premium) {
        await _repository.updateParentalSettings((current) => current.withTimerDisabled(false));
      }
      return !(settings.timerDisabled && premium);
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
      return true;
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

  void _deal(RoundPosition position) {
    _stopTimer();
    _previewTimer?.cancel();
    _round++;
    _position = position;
    final MemoryLevel level = MemoryLadder.levelAt(position.level);
    final MemoryBoardContent content = MemoryThemes.pick(_random, pairs: level.pairs);
    var id = 0;
    final cards = [
      for (final symbol in content.symbols) ...[
        MemoryCard(id: id++, assetPath: symbol),
        MemoryCard(id: id++, assetPath: symbol),
      ],
    ]..shuffle(_random);
    // La vista previa es una ayuda: solo en Fácil y Normal (HU-030 R10).
    final bool preview = position.round.showsHelps && _preview > Duration.zero;
    emit(MemoryLadderState(
      phase: preview ? MemoryRoundPhase.previewing : MemoryRoundPhase.playing,
      round: _round,
      position: MemoryLadderPosition(level: position.level, timeLimit: position.timeLimit),
      cards: preview ? [for (final card in cards) card.copyWith(isFaceUp: true)] : cards,
      hasBadge: _progress.bestMedal != null,
      goldFraction: _progress.goldFraction(_ladder),
      gameRound: position.round,
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
    final RoundPosition won = _position;
    // El tutorial no da estrellas (HU-037 P2).
    final int stars = won.isTutorial ? 0 : MemoryStars.forWin(level: won.level, moves: state.moves);
    final RoundStep step = _ladder.afterWin(won, timed: _timed);
    _progress = _progress.recordWin(won: won, stars: stars, step: step, at: _now());
    unawaited(_saveProgress());
    if (step.fromTutorial) {
      emit(state.copyWith(phase: MemoryRoundPhase.inviting, isProcessing: true));
      _scheduleNextRound(invitationDuration, step.next);
      return;
    }
    emit(state.copyWith(
      phase: MemoryRoundPhase.celebrating,
      stars: stars,
      badgeEarned: step.medal != null,
      medal: step.medal,
      hasBadge: _progress.bestMedal != null,
      goldFraction: _progress.goldFraction(_ladder),
      isProcessing: true,
    ));
    _scheduleNextRound(celebrationDuration, step.next);
  }

  void _timeUp() {
    _stopTimer();
    final RoundStep step = _ladder.afterLoss(_position, timed: _timed);
    _progress = _progress.recordLoss(step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: MemoryRoundPhase.timeUp,
      elapsed: state.position.timeLimit,
      loss: step.droppedRound
          ? MemoryLoss.easierRound
          : step.next.isTutorial
              ? MemoryLoss.restart
              : MemoryLoss.fewerCards,
      isProcessing: true,
    ));
    _scheduleNextRound(timeUpDuration, step.next);
  }

  /// Antes del tablero siguiente se vuelve a leer «Jugar sin tiempo»: si
  /// cambió, se sigue en el mismo nivel con el límite de llegada (HU-030 R6).
  void _scheduleNextRound(Duration delay, RoundPosition next) {
    _transition?.cancel();
    _transition = Timer(delay, () async {
      if (isClosed) return;
      final bool timed = await _readTimed();
      if (isClosed) return;
      final RoundPosition position = timed == _timed
          ? next
          : RoundPosition(
              round: next.round,
              level: next.level,
              timeLimit: _ladder.limitFor(next.round, next.level, timed: timed),
              tutorialFalls: next.tutorialFalls,
            );
      _timed = timed;
      _deal(position);
    });
  }

  /// Un fallo al guardar no interrumpe el juego; se reporta (D-010).
  Future<void> _saveProgress() async {
    try {
      await _repository.saveGameProgress(GameId.memory, _progress);
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

