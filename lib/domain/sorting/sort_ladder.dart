/// Escalera de «Clasificar» (HU-027 4.1 a 4.3): 8 niveles (el 1 es el
/// tutorial), las ocho rondas de HU-051 y sus estrellas. Color primero, tamaño
/// después y, al final, las dos cosas a la vez.
library;

import '../progress/helps.dart';
import '../progress/round_ladder.dart';
import '../settings/game_difficulty.dart';
import '../shadows/shadow_ladder.dart';
import 'sort_catalog.dart';

/// Qué se clasifica en un tablero.
enum SortCriterion {
  /// Por color: bronce, plata y esmeralda.
  color,

  /// Por tamaño: oro, rubí y zafiro.
  size,

  /// Color y tamaño a la vez (P5): obsidiana y diamante.
  colorAndSize,
}

/// Un nivel: cuántos objetos y cuántas cestas de color reciben alguno, y si
/// lleva una cesta libre (desde esmeralda).
final class SortLevel {
  const SortLevel({required this.number, required this.objects, required this.baskets, this.freeBasket = false});

  final int number;
  final int objects;

  /// Cestas de color a las que va algún objeto del tablero.
  final int baskets;

  /// Una cesta más de un color que no tiene ningún objeto: distrae, como el
  /// sitio libre de «A su sitio». Solo cuenta desde esmeralda y en color.
  final bool freeBasket;
}

/// Cómo se juega un nivel de una ronda (HU-027 4.2).
final class SortRules {
  const SortRules({required this.round, required this.level, this.timerDisabled = false});

  final GameDifficulty round;
  final int level;

  /// «Jugar sin tiempo» (HU-030 R3).
  final bool timerDisabled;

  bool _from(GameDifficulty first) => round.index >= first.index;

  SortCriterion get criterion => switch (round) {
        GameDifficulty.bronze || GameDifficulty.silver || GameDifficulty.emerald => SortCriterion.color,
        GameDifficulty.gold || GameDifficulty.ruby || GameDifficulty.sapphire => SortCriterion.size,
        GameDifficulty.obsidian || GameDifficulty.diamond => SortCriterion.colorAndSize,
      };

  /// Los 4 colores; naranja y morado desde esmeralda (P4).
  List<SortColor> get colors => _from(GameDifficulty.emerald) ? SortColor.values : SortColor.basic;

  /// Los tamaños del tablero (4.2):
  /// - oro y obsidiana: grande y pequeño;
  /// - rubí y zafiro: los tres desde el nivel 3 (antes, grande y pequeño);
  /// - diamante: la pareja de tamaños cambia con el nivel (grande y pequeño en
  ///   el 2 y el 5, grande y mediano en el 3 y el 6, mediano y pequeño en el 4
  ///   y el 7) y el nivel 8 tiene los tres (4.3).
  List<SortSize> get sizes {
    const List<SortSize> bigSmall = [SortSize.big, SortSize.small];
    return switch (round) {
      GameDifficulty.ruby || GameDifficulty.sapphire => level <= 2 ? bigSmall : SortSize.values,
      GameDifficulty.diamond => switch (level) {
          8 => SortSize.values,
          3 || 6 => const [SortSize.big, SortSize.medium],
          4 || 7 => const [SortSize.medium, SortSize.small],
          _ => bigSmall,
        },
      _ => bigSmall,
    };
  }

  /// Emojis distintos en un tablero de tamaño: uno en oro y rubí (se compara
  /// la misma cosa), dos en zafiro.
  int get sizeObjects => round == GameDifficulty.sapphire ? 2 : 1;

  /// Cesta libre desde esmeralda, solo en color (en tamaño, una cesta
  /// «mediana» vacía confundiría).
  bool get freeBaskets => criterion == SortCriterion.color && _from(GameDifficulty.emerald);

  /// Sin tiempo en bronce y plata (la muestra gratis para los más pequeños,
  /// D-043); desde oro, salvo «Jugar sin tiempo».
  bool get timed => _from(GameDifficulty.gold) && !timerDisabled;

  /// Parte de su cesta que el objeto tiene que cubrir para encajar (el imán
  /// de Sombras, HU-050).
  double get coverageToSnap => ShadowRules(difficulty: round).coverageToSnap;

  /// En obsidiana y diamante, las cestas cambian de lado en cada tablero.
  bool get randomLayout => _from(GameDifficulty.obsidian);

  /// La muestra de la cesta es igual que los objetos (🍓 en la cesta, 🍓 en la
  /// bandeja) solo en los niveles 1 y 2 de bronce: es una ayuda, y las ayudas
  /// solo van en el tutorial y en bronce ([Helps], HU-027 P6).
  bool get sampleInTray => round == Helps.baseRound && level <= 2;

  /// Nivel 8 de diamante (4.3): 6 cestas (2 colores × 3 tamaños) y una bandeja
  /// que se repone: [refillVisible] objetos a la vista y, al clasificar uno,
  /// entra otro, hasta [refillTotal].
  bool get refill => round == GameDifficulty.diamond && level == SortLadder.maxLevel;

  static const int refillVisible = 4;
  static const int refillTotal = 12;

  /// El tiempo se cuenta por objeto: el nivel que se repone tiene más.
  double get timeFactor => refill ? refillTotal / SortLadder.levelAt(level).objects : 1;

  @override
  bool operator ==(Object other) =>
      other is SortRules && other.round == round && other.level == level && other.timerDisabled == timerDisabled;

  @override
  int get hashCode => Object.hash(round, level, timerDisabled);
}

abstract final class SortLadder {
  static const List<SortLevel> levels = [
    SortLevel(number: 1, objects: 2, baskets: 2),
    SortLevel(number: 2, objects: 4, baskets: 2),
    SortLevel(number: 3, objects: 5, baskets: 3),
    SortLevel(number: 4, objects: 6, baskets: 3, freeBasket: true),
    SortLevel(number: 5, objects: 6, baskets: 4, freeBasket: true),
    SortLevel(number: 6, objects: 7, baskets: 4, freeBasket: true),
    SortLevel(number: 7, objects: 8, baskets: 4, freeBasket: true),
    SortLevel(number: 8, objects: 8, baskets: 4, freeBasket: true),
  ];

  static int get maxLevel => levels.last.number;

  /// Como mucho 3 objetos por cesta: los 3 huecos de la tarjeta.
  static const int maxPerBasket = 3;

  /// Sin Premium se juegan bronce y plata, las rondas de color (HU-027 8).
  static const GameDifficulty lastFreeRound = GameDifficulty.silver;

  /// La ronda que se juega: sin Premium, como mucho la plata. Lo ganado en las
  /// otras se conserva (HU-042 P3).
  static GameDifficulty playableRound(GameDifficulty round, {required bool premium}) =>
      premium || round.index <= lastFreeRound.index ? round : lastFreeRound;

  /// Las ocho rondas con los tiempos de Sombras, como «A su sitio». En bronce
  /// y plata no se usan: se juegan sin tiempo.
  static final RoundLadder rounds = RoundLadder(
    levels: levels.length,
    timeLimits: {for (final GameDifficulty round in GameDifficulty.values) round: ShadowLadder.timeLimitsFor(round)},
  );

  static SortLevel levelAt(int number) {
    RangeError.checkValueInInterval(number, 1, maxLevel, 'number');
    return levels[number - 1];
  }
}

/// Estrellas de un tablero (HU-027 4.2), como «A su sitio»: cuenta como fallo
/// cada objeto soltado en una cesta equivocada. Con N objetos, 3★ con N fallos
/// o menos, 2★ hasta 2N y 1★ con más.
abstract final class SortStars {
  static const int max = 3;

  static int forWin({required int objects, required int fails}) {
    RangeError.checkValueInInterval(objects, 1, 99, 'objects');
    RangeError.checkNotNegative(fails, 'fails');
    if (fails <= objects) return 3;
    if (fails <= objects * 2) return 2;
    return 1;
  }
}
