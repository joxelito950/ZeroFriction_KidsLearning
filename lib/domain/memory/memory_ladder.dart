/// Escalera del juego de memoria (HU-001, D-020): tableros de 2×2 a 4×4 y
/// límites de tiempo sin tiempo → 90 → 60 → 45 → 30 s en Normal. Fácil los
/// multiplica por 3 e Imposible los divide entre 2 (HU-030, D-035). Sin tiempo
/// (HU-030 R3), ningún nivel tiene límite y nunca se pierde.
library;

import '../progress/round_ladder.dart';
import '../settings/game_difficulty.dart';

/// Un nivel de la escalera.
final class MemoryLevel {
  const MemoryLevel({required this.number, required this.pairs});

  final int number;
  final int pairs;

  int get cards => pairs * 2;
}

/// Dónde está el niño en la escalera: el nivel y el límite de tiempo
/// (`null` = sin tiempo).
final class MemoryLadderPosition {
  const MemoryLadderPosition({required this.level, this.timeLimit});

  final int level;
  final Duration? timeLimit;

  bool get isTimed => timeLimit != null;

  @override
  bool operator ==(Object other) =>
      other is MemoryLadderPosition && other.level == level && other.timeLimit == timeLimit;

  @override
  int get hashCode => Object.hash(level, timeLimit);

  @override
  String toString() => 'MemoryLadderPosition(level: $level, timeLimit: $timeLimit)';
}

/// Por qué se baja de nivel al perder (para elegir el mensaje, R15).
enum MemoryLoss {
  /// Se baja un nivel: «Probemos con menos cartas».
  fewerCards,

  /// Se pierde en el 2×2 cronometrado: «Empecemos de nuevo, sin prisa».
  restart,

  /// Segunda caída al tutorial: se baja a la ronda anterior (HU-037 R10).
  easierRound,
}

/// Cómo se juega la escalera: la dificultad y si hay tiempo (HU-030).
final class MemoryLadderRules {
  const MemoryLadderRules({this.difficulty = GameDifficulty.gold, this.timed = true});

  final GameDifficulty difficulty;
  final bool timed;

  static const MemoryLadderRules standard = MemoryLadderRules();

  /// Límites con los que se llega a los niveles 2 a 5.
  List<Duration> get timeLimits => MemoryLadder.timeLimitsFor(difficulty);

  /// La vista previa de las cartas (HU-030 3.4) es una ayuda: se acorta ronda
  /// a ronda y desaparece en obsidiana y diamante (HU-051 3.1).
  bool get preview => MemoryLadder.previewFor(difficulty) > Duration.zero;

  @override
  bool operator ==(Object other) =>
      other is MemoryLadderRules && other.difficulty == difficulty && other.timed == timed;

  @override
  int get hashCode => Object.hash(difficulty, timed);
}

/// Resultado de aplicar una victoria o una derrota a una posición.
final class MemoryLadderStep {
  const MemoryLadderStep({required this.next, this.badgeEarned = false, this.loss});

  final MemoryLadderPosition next;

  /// Se acaba de superar el último nivel (insignia, R7).
  final bool badgeEarned;

  /// Tipo de derrota, o `null` si se ganó.
  final MemoryLoss? loss;
}

abstract final class MemoryLadder {
  static const List<MemoryLevel> levels = [
    MemoryLevel(number: 1, pairs: 2),
    MemoryLevel(number: 2, pairs: 3),
    MemoryLevel(number: 3, pairs: 4),
    MemoryLevel(number: 4, pairs: 6),
    MemoryLevel(number: 5, pairs: 8),
  ];

  /// Segundos con los que se llega a los niveles 2 a 5 en cada ronda (HU-051
  /// 3.1): bajan un 22–25 % por ronda, del bronce (el Fácil de HU-030) al
  /// diamante (el antiguo Reto máximo). Se revisan en la prueba cerrada.
  static const Map<GameDifficulty, List<int>> _seconds = {
    GameDifficulty.bronze: [270, 180, 135, 90],
    GameDifficulty.silver: [210, 140, 105, 70],
    GameDifficulty.gold: [160, 105, 80, 55],
    GameDifficulty.ruby: [125, 83, 63, 42],
    GameDifficulty.emerald: [95, 63, 48, 32],
    GameDifficulty.sapphire: [75, 50, 37, 25],
    GameDifficulty.obsidian: [58, 38, 29, 20],
    GameDifficulty.diamond: [45, 30, 22, 15],
  };

  static List<Duration> timeLimitsFor(GameDifficulty difficulty) =>
      [for (final int value in _seconds[difficulty]!) Duration(seconds: value)];

  /// Cuánto se ven las cartas antes de voltearse (HU-030 3.4): una ayuda que
  /// se acorta ronda a ronda y desaparece en obsidiana y diamante (HU-051 3.1).
  static Duration previewFor(GameDifficulty difficulty) => switch (difficulty) {
        GameDifficulty.bronze => const Duration(milliseconds: 2000),
        GameDifficulty.silver => const Duration(milliseconds: 1500),
        GameDifficulty.gold || GameDifficulty.ruby => const Duration(milliseconds: 1000),
        GameDifficulty.emerald => const Duration(milliseconds: 700),
        GameDifficulty.sapphire => const Duration(milliseconds: 500),
        GameDifficulty.obsidian || GameDifficulty.diamond => Duration.zero,
      };

  static int get maxLevel => levels.last.number;

  /// La escalera en rondas (HU-037, HU-051): el 2×2 es el tutorial y cada
  /// ronda usa su serie.
  static final RoundLadder rounds = RoundLadder(
    levels: levels.length,
    timeLimits: {for (final GameDifficulty round in GameDifficulty.values) round: timeLimitsFor(round)},
  );

  /// Primera partida y reinicios: nivel 1 sin tiempo (R3, R6, R8).
  static const MemoryLadderPosition start = MemoryLadderPosition(level: 1);

  static MemoryLevel levelAt(int number) {
    RangeError.checkValueInInterval(number, 1, maxLevel, 'number');
    return levels[number - 1];
  }

  /// Posición al volver a entrar al juego en [level], o al cambiar las reglas:
  /// el límite con el que se llega a ese nivel subiendo (tabla 4.1, R12;
  /// HU-030 R6). Sin tiempo, ningún nivel tiene límite.
  static MemoryLadderPosition arrivalPosition(int level, [MemoryLadderRules rules = MemoryLadderRules.standard]) {
    levelAt(level);
    if (level == 1 || !rules.timed) return MemoryLadderPosition(level: level);
    return MemoryLadderPosition(level: level, timeLimit: rules.timeLimits[level - 2]);
  }

  /// Al ganar: sube un nivel y el límite pasa al siguiente de la serie, sin
  /// bajar del último (R4). Ganar el último nivel da la insignia y reinicia
  /// (R7, R8). Sin tiempo, se sube sin límite (HU-030 R3).
  static MemoryLadderStep afterWin(MemoryLadderPosition position, [MemoryLadderRules rules = MemoryLadderRules.standard]) {
    levelAt(position.level);
    if (position.level == maxLevel) {
      return const MemoryLadderStep(next: start, badgeEarned: true);
    }
    final int level = position.level + 1;
    if (!rules.timed) return MemoryLadderStep(next: MemoryLadderPosition(level: level));
    return MemoryLadderStep(
      next: MemoryLadderPosition(level: level, timeLimit: _nextLimit(position.timeLimit, rules.timeLimits)),
    );
  }

  /// Al perder (el tiempo llega a 0): baja un nivel conservando el límite (R5);
  /// en el nivel 1 cronometrado, reinicia sin tiempo (R6).
  static MemoryLadderStep afterLoss(MemoryLadderPosition position) {
    levelAt(position.level);
    if (!position.isTimed) {
      throw StateError('A level without time limit cannot be lost: $position');
    }
    if (position.level == 1) {
      return const MemoryLadderStep(next: start, loss: MemoryLoss.restart);
    }
    return MemoryLadderStep(
      next: MemoryLadderPosition(level: position.level - 1, timeLimit: position.timeLimit),
      loss: MemoryLoss.fewerCards,
    );
  }

  static Duration _nextLimit(Duration? current, List<Duration> series) {
    if (current == null) return series.first;
    final int index = series.indexOf(current);
    if (index < 0) {
      throw ArgumentError.value(current, 'timeLimit', 'is not part of the time limit series');
    }
    return series[(index + 1).clamp(0, series.length - 1)];
  }
}
