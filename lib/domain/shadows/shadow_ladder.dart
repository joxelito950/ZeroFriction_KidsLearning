/// Escalera del juego Sombras (HU-007): 8 niveles, el 1 al 7 gratis y sin
/// tiempo; con Premium, el nivel 8, la barra de tiempo por dificultad y la
/// medalla (sección 3, D-028).
library;

import 'dart:math';

import '../progress/round_ladder.dart';
import '../settings/game_difficulty.dart';

/// Un nivel: cuántos objetos hay en la bandeja, cuántas sombras y si todos son
/// de la misma temática (tabla 4.2).
final class ShadowLevel {
  const ShadowLevel({required this.number, required this.objects, required this.shadows, this.sameTheme = false});

  final int number;
  final int objects;
  final int shadows;

  /// Formas de una misma temática: más parecidas, más difícil.
  final bool sameTheme;

  /// Sombras sin objeto (distractores) en Normal e Imposible.
  int get freeShadows => shadows - objects;
}

/// Dónde van las sombras respecto a la bandeja (4.1, P13, P14). El eje lo
/// decide la orientación: en vertical, arriba o abajo; en horizontal, a la
/// izquierda o a la derecha **físicas**, también en árabe (depende de la mano,
/// no del sentido de lectura).
enum ShadowLayout {
  /// Sombras arriba (vertical) o a la izquierda (horizontal): el destino queda
  /// a la vista de un diestro. Siempre en Fácil y Normal.
  shadowsFirst,

  /// Sombras abajo o a la derecha: solo puede tocar en Imposible.
  shadowsLast,
}

/// Cómo se juega la escalera: dificultad, Premium y si hay tiempo (HU-030).
final class ShadowRules {
  const ShadowRules({this.difficulty = GameDifficulty.normal, this.premium = false, this.timerDisabled = false});

  final GameDifficulty difficulty;
  final bool premium;

  /// «Jugar sin tiempo» (HU-030 R3); solo cuenta con Premium.
  final bool timerDisabled;

  /// El tiempo solo existe con Premium, y el adulto puede quitarlo (R6, R7, R18).
  bool get timed => premium && !timerDisabled;

  /// Sin Premium, el último nivel es el 7 (R6).
  int get lastLevel => premium ? ShadowLadder.maxLevel : ShadowLadder.maxLevel - 1;

  /// En Fácil no hay sombras libres (HU-030 3.2).
  bool get freeShadows => difficulty != GameDifficulty.easy;

  /// La animación de inicio es una ayuda: no va en Imposible (R19, HU-030 R10).
  bool get startAnimation => difficulty.showsHelps;

  /// En Imposible, la disposición cambia al azar en cada tablero (P14).
  bool get randomLayout => difficulty == GameDifficulty.impossible;

  /// Disposición de un tablero nuevo: en Imposible, al azar (P14).
  ShadowLayout layoutFor(Random random) => randomLayout
      ? ShadowLayout.values[random.nextInt(ShadowLayout.values.length)]
      : ShadowLayout.shadowsFirst;

  /// Parte de su sombra que el objeto tiene que cubrir para colocarse (P4).
  double get coverageToSnap => switch (difficulty) {
        GameDifficulty.easy => 0.4,
        GameDifficulty.normal => 0.6,
        GameDifficulty.impossible => 0.9,
      };

  @override
  bool operator ==(Object other) =>
      other is ShadowRules &&
      other.difficulty == difficulty &&
      other.premium == premium &&
      other.timerDisabled == timerDisabled;

  @override
  int get hashCode => Object.hash(difficulty, premium, timerDisabled);
}

/// Nivel y límite de tiempo (`null` = sin tiempo).
final class ShadowPosition {
  const ShadowPosition({required this.level, this.timeLimit});

  final int level;
  final Duration? timeLimit;

  bool get isTimed => timeLimit != null;

  @override
  bool operator ==(Object other) => other is ShadowPosition && other.level == level && other.timeLimit == timeLimit;

  @override
  int get hashCode => Object.hash(level, timeLimit);

  @override
  String toString() => 'ShadowPosition(level: $level, timeLimit: $timeLimit)';
}

/// Resultado de ganar o perder un tablero.
final class ShadowStep {
  const ShadowStep({required this.next, this.medalEarned = false, this.lost = false});

  final ShadowPosition next;

  /// Se superó el nivel 8 con Premium (R10).
  final bool medalEarned;

  /// Se acabó el tiempo.
  final bool lost;
}

abstract final class ShadowLadder {
  static const List<ShadowLevel> levels = [
    ShadowLevel(number: 1, objects: 2, shadows: 2),
    ShadowLevel(number: 2, objects: 3, shadows: 3),
    ShadowLevel(number: 3, objects: 4, shadows: 4),
    ShadowLevel(number: 4, objects: 4, shadows: 5),
    ShadowLevel(number: 5, objects: 5, shadows: 6),
    ShadowLevel(number: 6, objects: 5, shadows: 6, sameTheme: true),
    ShadowLevel(number: 7, objects: 6, shadows: 7, sameTheme: true),
    ShadowLevel(number: 8, objects: 6, shadows: 8, sameTheme: true),
  ];

  static int get maxLevel => levels.last.number;

  /// La escalera en rondas (HU-037): el nivel 1 es el tutorial y cada ronda usa
  /// su serie de la tabla 4.3.
  static final RoundLadder rounds = RoundLadder(
    levels: levels.length,
    timeLimits: {for (final GameDifficulty round in GameDifficulty.values) round: timeLimitsFor(round)},
  );

  /// Sin Premium, cada ronda termina en el nivel 7 y da su medalla; el nivel 8
  /// es el extra de Premium (HU-037 P16).
  static int lastLevelFor({required bool premium}) => premium ? maxLevel : maxLevel - 1;

  static const ShadowPosition start = ShadowPosition(level: 1);

  /// Límites con los que se llega a los niveles 2 a 8 (tabla 4.3).
  static List<Duration> timeLimitsFor(GameDifficulty difficulty) => switch (difficulty) {
        GameDifficulty.easy => _seconds(const [90, 80, 70, 60, 50, 40, 30]),
        GameDifficulty.normal => _seconds(const [60, 50, 45, 40, 35, 30, 25]),
        GameDifficulty.impossible => _seconds(const [50, 45, 40, 35, 30, 25, 20]),
      };

  static List<Duration> _seconds(List<int> values) => [for (final value in values) Duration(seconds: value)];

  static ShadowLevel levelAt(int number) {
    RangeError.checkValueInInterval(number, 1, maxLevel, 'number');
    return levels[number - 1];
  }

  /// Posición al abrir el juego o al cambiar las reglas: el límite con el que se
  /// llega al nivel subiendo. Sin Premium, el nivel 8 no existe y se juega el 7.
  static ShadowPosition arrivalPosition(int level, ShadowRules rules) {
    levelAt(level);
    final int playable = level > rules.lastLevel ? rules.lastLevel : level;
    if (playable == 1 || !rules.timed) return ShadowPosition(level: playable);
    return ShadowPosition(level: playable, timeLimit: timeLimitsFor(rules.difficulty)[playable - 2]);
  }

  /// Al ganar: sube un nivel con el siguiente límite. Superar el último nivel
  /// vuelve al 1; con Premium (nivel 8), da la medalla (R6, R10).
  static ShadowStep afterWin(ShadowPosition position, ShadowRules rules) {
    levelAt(position.level);
    if (position.level >= rules.lastLevel) {
      return ShadowStep(next: start, medalEarned: rules.premium && position.level == maxLevel);
    }
    return ShadowStep(next: arrivalPosition(position.level + 1, rules));
  }

  /// Al perder por tiempo: baja un nivel conservando el límite; en el nivel 1
  /// cronometrado, vuelve a empezar sin tiempo (como HU-001 R5, R6).
  static ShadowStep afterLoss(ShadowPosition position) {
    levelAt(position.level);
    if (!position.isTimed) throw StateError('A board without time cannot be lost: $position');
    if (position.level == 1) return const ShadowStep(next: start, lost: true);
    return ShadowStep(next: ShadowPosition(level: position.level - 1, timeLimit: position.timeLimit), lost: true);
  }
}

/// Estrellas de un nivel (R9): se cuentan los fallos de forma (soltar sobre una
/// sombra equivocada). Con N objetos: 1★ con como mucho 2N fallos, 2★ con como
/// mucho N y 3★ con como mucho N y Premium, con o sin tiempo.
abstract final class ShadowStars {
  static const int max = 3;

  static int forWin({required int objects, required int fails, required bool premium}) {
    RangeError.checkNotNegative(fails, 'fails');
    if (fails <= objects) return premium ? 3 : 2;
    if (fails <= objects * 2) return 1;
    return 0;
  }
}
