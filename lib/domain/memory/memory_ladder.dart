/// Escalera del juego de memoria (HU-001, D-020): tableros de 2×2 a 4×4 y
/// límites de tiempo sin tiempo → 90 → 60 → 45 → 30 s.
library;

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

  static const List<Duration> timeLimits = [
    Duration(seconds: 90),
    Duration(seconds: 60),
    Duration(seconds: 45),
    Duration(seconds: 30),
  ];

  static int get maxLevel => levels.last.number;

  /// Primera partida y reinicios: nivel 1 sin tiempo (R3, R6, R8).
  static const MemoryLadderPosition start = MemoryLadderPosition(level: 1);

  static MemoryLevel levelAt(int number) {
    RangeError.checkValueInInterval(number, 1, maxLevel, 'number');
    return levels[number - 1];
  }

  /// Posición al volver a entrar al juego en [level]: el límite con el que se
  /// llega a ese nivel subiendo (tabla 4.1, R12).
  static MemoryLadderPosition arrivalPosition(int level) {
    levelAt(level);
    if (level == 1) return start;
    return MemoryLadderPosition(level: level, timeLimit: timeLimits[level - 2]);
  }

  /// Al ganar: sube un nivel y el límite pasa al siguiente de la serie, sin
  /// bajar de 30 s (R4). Ganar el último nivel da la insignia y reinicia (R7, R8).
  static MemoryLadderStep afterWin(MemoryLadderPosition position) {
    levelAt(position.level);
    if (position.level == maxLevel) {
      return const MemoryLadderStep(next: start, badgeEarned: true);
    }
    return MemoryLadderStep(
      next: MemoryLadderPosition(level: position.level + 1, timeLimit: _nextLimit(position.timeLimit)),
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

  static Duration _nextLimit(Duration? current) {
    if (current == null) return timeLimits.first;
    final int index = timeLimits.indexOf(current);
    if (index < 0) {
      throw ArgumentError.value(current, 'timeLimit', 'is not part of the time limit series');
    }
    return timeLimits[(index + 1).clamp(0, timeLimits.length - 1)];
  }
}
