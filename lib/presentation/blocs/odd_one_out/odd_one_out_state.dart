import 'package:meta/meta.dart';

import '../../../domain/settings/game_difficulty.dart';

/// Fase de un nivel de «¿Cuál es diferente?» (HU-025).
enum OddPhase {
  loading,

  /// Tablero en juego.
  playing,

  /// Acertó: el diferente salta y llega el siguiente tablero (R3). Tocar no hace nada.
  solved,

  /// Nivel completado: celebración con las estrellas (como R8 de HU-007).
  celebrating,

  /// Tutorial superado: invitación a jugar (HU-037 R9).
  inviting,

  /// Se acabó el tiempo.
  timeUp,
}

/// Qué pasa tras perder por tiempo, para el mensaje.
enum OddLoss { fewerObjects, restart, easierRound }

@immutable
class OddOneOutState {
  const OddOneOutState({
    this.phase = OddPhase.loading,
    this.round = 0,
    this.gameRound = GameDifficulty.easy,
    this.level = 1,
    this.timeLimit,
    this.board = 0,
    this.objects = const [],
    this.oddIndex = 0,
    this.fails = 0,
    this.wrongIndex,
    this.wrongCount = 0,
    this.elapsed = Duration.zero,
    this.timerStarted = false,
    this.stars,
    this.medal,
    this.hasMedal = false,
    this.goldFraction = 0,
    this.loss,
  });

  final OddPhase phase;

  /// Número de tablero repartido; cambia con cada tablero (para animar).
  final int round;

  /// Ronda de dificultad en juego (HU-037).
  final GameDifficulty gameRound;
  final int level;

  /// Límite del nivel (los 3 tableros); `null` sin tiempo.
  final Duration? timeLimit;

  /// Tablero del nivel, de 0 a 2.
  final int board;
  final List<String> objects;
  final int oddIndex;

  /// Fallos del nivel (R4).
  final int fails;

  /// Último objeto tocado por error y cuántos van: cambia en cada fallo para
  /// repetir el «no» aunque se toque el mismo (R3).
  final int? wrongIndex;
  final int wrongCount;

  final Duration elapsed;
  final bool timerStarted;
  final int? stars;
  final GameDifficulty? medal;
  final bool hasMedal;
  final double goldFraction;
  final OddLoss? loss;

  bool get isTimed => timeLimit != null;

  /// Fracción de tiempo restante (1 = barra llena), o `null` sin tiempo.
  double? get remainingFraction {
    final Duration? limit = timeLimit;
    if (limit == null) return null;
    final Duration left = limit - elapsed;
    return (left.isNegative ? Duration.zero : left).inMilliseconds / limit.inMilliseconds;
  }

  OddOneOutState copyWith({
    OddPhase? phase,
    int? fails,
    int? wrongIndex,
    int? wrongCount,
    Duration? elapsed,
    bool? timerStarted,
    int? stars,
    GameDifficulty? medal,
    bool? hasMedal,
    double? goldFraction,
    OddLoss? loss,
  }) =>
      OddOneOutState(
        phase: phase ?? this.phase,
        round: round,
        gameRound: gameRound,
        level: level,
        timeLimit: timeLimit,
        board: board,
        objects: objects,
        oddIndex: oddIndex,
        fails: fails ?? this.fails,
        wrongIndex: wrongIndex ?? this.wrongIndex,
        wrongCount: wrongCount ?? this.wrongCount,
        elapsed: elapsed ?? this.elapsed,
        timerStarted: timerStarted ?? this.timerStarted,
        stars: stars ?? this.stars,
        medal: medal ?? this.medal,
        hasMedal: hasMedal ?? this.hasMedal,
        goldFraction: goldFraction ?? this.goldFraction,
        loss: loss ?? this.loss,
      );
}
