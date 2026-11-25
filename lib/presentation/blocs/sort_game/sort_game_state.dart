import 'package:meta/meta.dart';

import '../../../domain/settings/game_difficulty.dart';
import '../../../domain/sorting/sort_board.dart';
import '../../../domain/sorting/sort_catalog.dart';

/// Fase de un tablero de «Clasificar» (HU-027).
enum SortPhase {
  /// Leyendo el progreso guardado.
  loading,

  /// Tablero en juego.
  playing,

  /// Tablero completado: celebración con las estrellas.
  celebrating,

  /// Se acabó el tiempo: aviso antes de bajar de nivel.
  timeUp,

  /// Tutorial superado (HU-037 R9): invitación a jugar, sin estrellas.
  inviting,
}

/// Qué pasa tras perder por tiempo (HU-037), como en «A su sitio».
enum SortLoss { fewerObjects, restart, easierRound }

/// Estado inmutable de la pantalla de «Clasificar».
@immutable
class SortGameState {
  const SortGameState({
    this.phase = SortPhase.loading,
    this.round = 0,
    this.level = 1,
    this.timeLimit,
    this.board,
    this.basketsFirst = true,
    this.placed = const {},
    this.fails = 0,
    this.moves = 0,
    this.elapsed = Duration.zero,
    this.timerStarted = false,
    this.coverageToSnap = 0.4,
    this.stars,
    this.medal,
    this.gameRound = GameDifficulty.bronze,
    this.lossKind,
  });

  final SortPhase phase;

  /// Número de tablero repartido; cambia con cada tablero nuevo.
  final int round;
  final int level;

  /// Límite del tablero, o `null` sin tiempo (bronce, plata, tutorial o
  /// «Jugar sin tiempo»).
  final Duration? timeLimit;
  final SortBoard? board;

  /// Cestas arriba o a la izquierda (siempre, salvo al azar en obsidiana y
  /// diamante, HU-027 4.2).
  final bool basketsFirst;

  /// Objetos ya en su cesta (por su id): no se pueden mover. En el orden en
  /// que llegaron.
  final Set<String> placed;

  /// Objetos soltados en una cesta equivocada (las estrellas).
  final int fails;

  /// Movimientos del tablero (HU-039 R7): cada vez que se suelta un objeto sobre
  /// una cesta, o se toca una cesta con un objeto elegido, acierte o no.
  final int moves;
  final Duration elapsed;

  /// El cronómetro arranca al tocar el primer objeto.
  final bool timerStarted;

  /// Parte del objeto que tiene que caer sobre su cesta para encajar.
  final double coverageToSnap;

  /// Estrellas del tablero recién completado.
  final int? stars;

  /// Medalla de la ronda recién completada.
  final GameDifficulty? medal;

  /// Ronda en juego: da color a los puntos de nivel.
  final GameDifficulty gameRound;
  final SortLoss? lossKind;

  List<SortPiece> get pieces => board?.pieces ?? const [];

  List<SortPiece> get trayPieces => [
        for (final SortPiece piece in pieces)
          if (!placed.contains(piece.id)) piece,
      ];

  /// Objetos ya en [basket], en el orden en que llegaron: el primero ocupa el
  /// primer hueco.
  List<SortPiece> placedAt(SortColor basket) => [
        for (final String id in placed)
          if (board!.pieceById(id) case final SortPiece piece when piece.color == basket) piece,
      ];

  bool canDrag(String id) =>
      phase == SortPhase.playing && pieces.any((piece) => piece.id == id) && !placed.contains(id);

  /// Fracción de tiempo restante (1 = barra llena), o `null` sin tiempo.
  double? get remainingFraction {
    final Duration? limit = timeLimit;
    if (limit == null) return null;
    final Duration left = limit - elapsed;
    return left.isNegative ? 0 : left.inMilliseconds / limit.inMilliseconds;
  }

  SortGameState copyWith({
    SortPhase? phase,
    Set<String>? placed,
    int? fails,
    int? moves,
    Duration? elapsed,
    bool? timerStarted,
    int? stars,
    GameDifficulty? medal,
    SortLoss? lossKind,
  }) =>
      SortGameState(
        phase: phase ?? this.phase,
        round: round,
        level: level,
        timeLimit: timeLimit,
        board: board,
        basketsFirst: basketsFirst,
        placed: placed ?? this.placed,
        fails: fails ?? this.fails,
        moves: moves ?? this.moves,
        elapsed: elapsed ?? this.elapsed,
        timerStarted: timerStarted ?? this.timerStarted,
        coverageToSnap: coverageToSnap,
        stars: stars ?? this.stars,
        medal: medal ?? this.medal,
        gameRound: gameRound,
        lossKind: lossKind ?? this.lossKind,
      );
}
