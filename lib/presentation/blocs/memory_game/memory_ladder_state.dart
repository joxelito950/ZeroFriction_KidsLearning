import 'package:meta/meta.dart';

import '../../../domain/memory/memory_ladder.dart';
import 'memory_card_model.dart';

/// Fase de una ronda del juego de memoria progresivo (HU-001).
enum MemoryRoundPhase {
  /// Leyendo el progreso guardado.
  loading,

  /// Tablero en juego.
  playing,

  /// Ronda ganada: celebración automática con las estrellas (R14).
  celebrating,

  /// Se acabó el tiempo: aviso automático antes de bajar de nivel (R15).
  timeUp,
}

/// Estado inmutable de la pantalla del juego de memoria progresivo.
@immutable
class MemoryLadderState {
  const MemoryLadderState({
    this.phase = MemoryRoundPhase.loading,
    this.position = MemoryLadder.start,
    this.cards = const [],
    this.firstSelectedCardIndex,
    this.isProcessing = false,
    this.moves = 0,
    this.elapsed = Duration.zero,
    this.timerStarted = false,
    this.stars,
    this.badgeEarned = false,
    this.loss,
    this.hasBadge = false,
  });

  final MemoryRoundPhase phase;
  final MemoryLadderPosition position;
  final List<MemoryCard> cards;
  final int? firstSelectedCardIndex;
  final bool isProcessing;
  final int moves;

  /// Tiempo de juego consumido en esta ronda.
  final Duration elapsed;

  /// El cronómetro arranca al tocar la primera carta (R10).
  final bool timerStarted;

  /// Estrellas de la ronda recién ganada (fase [MemoryRoundPhase.celebrating]).
  final int? stars;

  /// La ronda recién ganada dio la insignia (celebración dorada, R14).
  final bool badgeEarned;

  /// Tipo de derrota (fase [MemoryRoundPhase.timeUp]), para elegir el mensaje.
  final MemoryLoss? loss;

  /// El niño ya tiene la insignia (permanente).
  final bool hasBadge;

  int get level => position.level;

  /// Tiempo restante, o `null` si el nivel no tiene tiempo.
  Duration? get remaining {
    final Duration? limit = position.timeLimit;
    if (limit == null) return null;
    final Duration left = limit - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  /// Fracción de tiempo restante (1 = barra llena), o `null` si no hay tiempo.
  double? get remainingFraction {
    final Duration? limit = position.timeLimit;
    final Duration? left = remaining;
    if (limit == null || left == null) return null;
    return left.inMilliseconds / limit.inMilliseconds;
  }

  MemoryLadderState copyWith({
    MemoryRoundPhase? phase,
    List<MemoryCard>? cards,
    int? firstSelectedCardIndex,
    bool clearSelection = false,
    bool? isProcessing,
    int? moves,
    Duration? elapsed,
    bool? timerStarted,
    int? stars,
    bool? badgeEarned,
    MemoryLoss? loss,
    bool? hasBadge,
  }) {
    return MemoryLadderState(
      phase: phase ?? this.phase,
      position: position,
      cards: cards ?? this.cards,
      firstSelectedCardIndex:
          clearSelection ? null : (firstSelectedCardIndex ?? this.firstSelectedCardIndex),
      isProcessing: isProcessing ?? this.isProcessing,
      moves: moves ?? this.moves,
      elapsed: elapsed ?? this.elapsed,
      timerStarted: timerStarted ?? this.timerStarted,
      stars: stars ?? this.stars,
      badgeEarned: badgeEarned ?? this.badgeEarned,
      loss: loss ?? this.loss,
      hasBadge: hasBadge ?? this.hasBadge,
    );
  }
}
