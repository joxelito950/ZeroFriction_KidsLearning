/// Rondas de dificultad (HU-037; HU-051, D-042): cada juego tiene ocho rondas,
/// de bronce a diamante, con la misma escalera. El tutorial es el nivel 1 y
/// solo se juega una vez, al empezar el juego (HU-051 P5): cada ronda empieza
/// en su primer nivel con tiempo. Este archivo tiene las reglas comunes a todos
/// los juegos; cada juego aporta su [RoundLadder] (niveles y tiempos).
library;

import '../settings/game_difficulty.dart';

/// Las rondas, en orden de avance.
extension GameRound on GameDifficulty {
  /// La ronda siguiente; después del diamante se sigue en diamante (HU-037 P4).
  GameDifficulty get nextRound =>
      index == GameDifficulty.values.length - 1 ? this : GameDifficulty.values[index + 1];

  /// La ronda anterior, o `null` en bronce (R10): se baja un solo escalón
  /// (HU-051 R3).
  GameDifficulty? get previousRound => index == 0 ? null : GameDifficulty.values[index - 1];
}

/// La escalera de un juego: cuántos niveles tiene (el 1 es el tutorial) y el
/// límite de tiempo con el que se llega a cada nivel en cada ronda.
final class RoundLadder {
  RoundLadder({required this.levels, required Map<GameDifficulty, List<Duration>> timeLimits})
      : timeLimits = Map.unmodifiable(timeLimits) {
    RangeError.checkValueInInterval(levels, 2, 99, 'levels');
    for (final GameDifficulty round in GameDifficulty.values) {
      final List<Duration>? series = timeLimits[round];
      if (series == null || series.length != levels - 1) {
        throw ArgumentError.value(series, 'timeLimits[$round]', 'needs ${levels - 1} limits (levels 2 to $levels)');
      }
    }
  }

  /// Número de niveles, contando el tutorial.
  final int levels;

  /// Por ronda, los límites de los niveles 2 a [levels].
  final Map<GameDifficulty, List<Duration>> timeLimits;

  /// El tutorial siempre es el nivel 1 (R3).
  static const int tutorial = 1;

  /// El primer nivel con tiempo: donde se sigue al bajar de ronda (P14).
  static const int firstTimedLevel = 2;

  /// Niveles que dan estrellas en cada ronda: todos menos el tutorial (P2).
  int get levelsWithStars => levels - 1;

  /// Estrellas posibles en todas las rondas (HU-037 sección 10.3; con HU-051, ocho).
  int get maxStars => levelsWithStars * 3 * GameDifficulty.values.length;

  /// Límite con el que se llega a [level] en [round], o `null` en el tutorial
  /// o con «Jugar sin tiempo» ([timed] falso).
  Duration? limitFor(GameDifficulty round, int level, {bool timed = true}) {
    RangeError.checkValueInInterval(level, 1, levels, 'level');
    if (level == tutorial || !timed) return null;
    return timeLimits[round]![level - 2];
  }

  RoundPosition arrival(GameDifficulty round, int level, {bool timed = true}) =>
      RoundPosition(round: round, level: level, timeLimit: limitFor(round, level, timed: timed));

  /// Al ganar [position]. [lastLevel] es el último nivel jugable (en Sombras
  /// gratis, el 7: la ronda termina ahí, P16). Completar la ronda da su medalla
  /// y pasa al primer nivel con tiempo de la siguiente, sin repetir el tutorial
  /// (R2; HU-051 R3b); tras el tutorial, la invitación a jugar (R9).
  RoundStep afterWin(RoundPosition position, {int? lastLevel, bool timed = true}) {
    final int last = lastLevel ?? levels;
    RangeError.checkValueInInterval(last, 2, levels, 'lastLevel');
    if (position.level >= last) {
      return RoundStep(
        next: arrival(position.round.nextRound, firstTimedLevel, timed: timed),
        medal: position.round,
      );
    }
    final int level = position.level + 1;
    return RoundStep(
      next: RoundPosition(
        round: position.round,
        level: level,
        timeLimit: limitFor(position.round, level, timed: timed),
        tutorialFalls: position.tutorialFalls,
      ),
      fromTutorial: position.level == tutorial,
    );
  }

  /// Al perder por tiempo: se baja un nivel conservando el límite. En el primer
  /// nivel con tiempo se repite el nivel (el tutorial es solo del principio,
  /// HU-051 P5) y, si se pierde ahí por segunda vez en la ronda, se baja a la
  /// ronda anterior, en su primer nivel con tiempo (HU-051 P7; HU-037 R10, P14,
  /// P15). En bronce no hay ronda anterior: se repite.
  RoundStep afterLoss(RoundPosition position, {bool timed = true}) {
    if (!position.isTimed) throw StateError('A level without time cannot be lost: $position');
    if (position.level > firstTimedLevel) {
      return RoundStep(
        next: RoundPosition(
          round: position.round,
          level: position.level - 1,
          timeLimit: position.timeLimit,
          tutorialFalls: position.tutorialFalls,
        ),
        lost: true,
      );
    }
    final int falls = position.tutorialFalls + 1;
    final GameDifficulty? previous = position.round.previousRound;
    if (falls >= 2 && previous != null) {
      return RoundStep(next: arrival(previous, firstTimedLevel, timed: timed), lost: true, droppedRound: true);
    }
    return RoundStep(
      next: RoundPosition(
        round: position.round,
        level: firstTimedLevel,
        timeLimit: position.timeLimit,
        tutorialFalls: falls,
      ),
      lost: true,
      retry: true,
    );
  }
}

/// Dónde se juega: ronda, nivel, límite (`null` = sin tiempo) y cuántas veces
/// se ha perdido en el primer nivel con tiempo de esta ronda (HU-051 P7; el
/// nombre viene de cuando se caía al tutorial, HU-037 P15, y se guarda así).
final class RoundPosition {
  const RoundPosition({required this.round, required this.level, this.timeLimit, this.tutorialFalls = 0});

  final GameDifficulty round;
  final int level;
  final Duration? timeLimit;
  final int tutorialFalls;

  bool get isTimed => timeLimit != null;
  bool get isTutorial => level == RoundLadder.tutorial;

  @override
  bool operator ==(Object other) =>
      other is RoundPosition &&
      other.round == round &&
      other.level == level &&
      other.timeLimit == timeLimit &&
      other.tutorialFalls == tutorialFalls;

  @override
  int get hashCode => Object.hash(round, level, timeLimit, tutorialFalls);

  @override
  String toString() =>
      'RoundPosition(round: ${round.name}, level: $level, timeLimit: $timeLimit, falls: $tutorialFalls)';
}

/// Resultado de ganar o perder un nivel.
final class RoundStep {
  const RoundStep({
    required this.next,
    this.medal,
    this.fromTutorial = false,
    this.lost = false,
    this.droppedRound = false,
    this.retry = false,
  });

  final RoundPosition next;

  /// La ronda completada, si se ganó su medalla (R2).
  final GameDifficulty? medal;

  /// Se acaba de superar el tutorial: invitación a jugar, sin estrellas (R9).
  final bool fromTutorial;

  final bool lost;

  /// Se bajó a la ronda anterior (R10).
  final bool droppedRound;

  /// Se perdió en el primer nivel con tiempo y se repite (HU-051 P5, P7): el
  /// aviso es «empecemos de nuevo, sin prisa».
  final bool retry;
}
