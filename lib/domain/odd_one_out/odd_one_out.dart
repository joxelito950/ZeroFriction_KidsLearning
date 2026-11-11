/// Juego «¿Cuál es diferente?» (HU-025): en cada tablero, todos los objetos son
/// de un grupo menos uno. Escalera por rondas (HU-037), 3 tableros por nivel
/// (P3), estrellas por fallos y contenido de Emoji 5.0 o anterior (D-024, D-026).
library;

import 'dart:math';

import '../progress/round_ladder.dart';
import '../settings/game_difficulty.dart';

/// Qué separa al diferente de los demás en un nivel (sección 4 y 11.1).
enum OddKind {
  /// Grupos muy distintos (animal frente a vehículo).
  veryDifferent,

  /// Animales de granja frente a salvajes.
  farmOrWild,

  /// Vehículos de tierra frente a uno de aire.
  landOrAir,

  /// Un rasgo visible: rojos frente a uno amarillo.
  colour,
}

/// Un nivel: cuántos objetos hay en cada tablero y qué los diferencia.
final class OddLevel {
  const OddLevel({required this.number, required this.objects, required this.kind});

  final int number;
  final int objects;
  final OddKind kind;
}

/// Un grupo de emojis con su familia (los de familias distintas son «muy
/// distintos»).
final class OddGroup {
  const OddGroup({required this.id, required this.family, required this.symbols});

  final String id;
  final String family;
  final List<String> symbols;
}

/// Un tablero: los objetos en su orden y cuál es el diferente.
final class OddBoard {
  const OddBoard({required this.objects, required this.oddIndex});

  final List<String> objects;
  final int oddIndex;

  String get odd => objects[oddIndex];
}

abstract final class OddOneOut {
  static const List<OddLevel> levels = [
    OddLevel(number: 1, objects: 3, kind: OddKind.veryDifferent),
    OddLevel(number: 2, objects: 4, kind: OddKind.veryDifferent),
    OddLevel(number: 3, objects: 4, kind: OddKind.farmOrWild),
    OddLevel(number: 4, objects: 5, kind: OddKind.landOrAir),
    OddLevel(number: 5, objects: 6, kind: OddKind.colour),
  ];

  /// Tableros seguidos en cada nivel (P3); el tiempo es para los tres.
  static const int boardsPerLevel = 3;

  static int get maxLevel => levels.last.number;

  static OddLevel levelAt(int number) {
    RangeError.checkValueInInterval(number, 1, maxLevel, 'number');
    return levels[number - 1];
  }

  /// Tiempos por ronda para los niveles 2 a 5 (tabla 11.1).
  static final RoundLadder rounds = RoundLadder(
    levels: levels.length,
    timeLimits: {
      GameDifficulty.easy: _seconds(const [60, 50, 45, 40]),
      GameDifficulty.normal: _seconds(const [40, 35, 30, 25]),
      GameDifficulty.impossible: _seconds(const [25, 20, 18, 15]),
    },
  );

  static List<Duration> _seconds(List<int> values) => [for (final value in values) Duration(seconds: value)];

  /// La ronda Imposible es de Premium (HU-025 P1, HU-037 P6). Sin Premium se
  /// sigue en Normal tras la plata, como tras el oro se sigue en Imposible.
  static GameDifficulty playableRound(GameDifficulty round, {required bool premium}) =>
      !premium && round == GameDifficulty.impossible ? GameDifficulty.normal : round;

  static const List<OddGroup> groups = [
    OddGroup(id: 'farm', family: 'animals', symbols: ['🐮', '🐷', '🐔', '🐑', '🐴', '🐰']),
    OddGroup(id: 'wild', family: 'animals', symbols: ['🦁', '🐯', '🐘', '🦒', '🐻', '🐵']),
    OddGroup(id: 'water', family: 'animals', symbols: ['🐟', '🐳', '🐙', '🐢', '🦀']),
    OddGroup(id: 'fruits', family: 'food', symbols: ['🍎', '🍌', '🍐', '🍇', '🍓', '🍉', '🍒']),
    OddGroup(id: 'land', family: 'vehicles', symbols: ['🚗', '🚌', '🚲', '🚂', '🚜', '🚒']),
    OddGroup(id: 'air', family: 'vehicles', symbols: ['✈️', '🚁', '🚀']),
    OddGroup(id: 'clothes', family: 'clothes', symbols: ['👕', '👖', '👗', '👟', '🎩', '👒']),
    OddGroup(id: 'toys', family: 'toys', symbols: ['⚽', '🏀', '🎈', '🎁']),
    OddGroup(id: 'reds', family: 'colours', symbols: ['🍓', '🍎', '🍒', '🍅', '🚒', '🌶️']),
    OddGroup(id: 'yellows', family: 'colours', symbols: ['🍋', '🍌', '🌽']),
  ];

  static OddGroup group(String id) => groups.firstWhere((group) => group.id == id);

  /// Reparte un tablero de [level]: N−1 objetos distintos de un grupo y uno de
  /// otro, en una posición al azar (R2).
  static OddBoard board(Random random, OddLevel level) {
    final (OddGroup many, OddGroup odd) = switch (level.kind) {
      OddKind.veryDifferent => _differentFamilies(random, level.objects - 1),
      OddKind.farmOrWild => random.nextBool() ? (group('farm'), group('wild')) : (group('wild'), group('farm')),
      OddKind.landOrAir => (group('land'), group('air')),
      OddKind.colour => (group('reds'), group('yellows')),
    };
    final List<String> same = (List.of(many.symbols)..shuffle(random)).take(level.objects - 1).toList();
    final List<String> others = odd.symbols.where((symbol) => !same.contains(symbol)).toList();
    final String different = others[random.nextInt(others.length)];
    final int oddIndex = random.nextInt(level.objects);
    return OddBoard(objects: [...same]..insert(oddIndex, different), oddIndex: oddIndex);
  }

  /// Dos grupos de familias distintas; el de la mayoría tiene objetos de sobra.
  static (OddGroup, OddGroup) _differentFamilies(Random random, int needed) {
    final List<OddGroup> candidates =
        groups.where((group) => group.family != 'colours' && group.symbols.length >= needed).toList();
    final OddGroup many = candidates[random.nextInt(candidates.length)];
    final List<OddGroup> others = groups.where((group) => group.family != many.family && group.family != 'colours').toList();
    return (many, others[random.nextInt(others.length)]);
  }
}

/// Estrellas de un nivel por los fallos en sus 3 tableros (sección 11.2): 3★
/// con como mucho 1, 2★ con como mucho 3, 1★ con como mucho 6.
abstract final class OddOneOutStars {
  static int forWin({required int fails}) {
    RangeError.checkNotNegative(fails, 'fails');
    if (fails <= 1) return 3;
    if (fails <= 3) return 2;
    if (fails <= 6) return 1;
    return 0;
  }
}
