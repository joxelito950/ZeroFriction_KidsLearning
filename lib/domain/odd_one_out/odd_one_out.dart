/// Juego «¿Cuál es diferente?» (HU-025): en cada tablero, todos los objetos son
/// de un grupo menos uno. Escalera por rondas (HU-037), 3 tableros por nivel
/// (P3), estrellas por fallos y contenido de Emoji 5.0 o anterior (D-024, D-026).
///
/// **Cada ronda compara cosas distintas** (decidido el 2026-11-12, sección 13):
/// Fácil, lo que se ve a simple vista; Normal, a qué grupo pertenece cada cosa;
/// Reto máximo, categorías que piden pensar (selva o granja, tierra o aire).
library;

import 'dart:math';

import '../progress/round_ladder.dart';
import '../settings/game_difficulty.dart';

/// Qué separa al diferente de los demás.
enum OddKind {
  /// Fácil: la misma figura repetida y una distinta (🍎🍎🍎🐶).
  identical,

  /// Fácil: frutas distintas del mismo color y una de otro color (🍎🍓🍒🍌).
  colour,

  /// Normal: cosas muy relacionadas y una de otro mundo (🐮🐷🐔🚗).
  veryDifferent,

  /// Reto máximo: animales de la selva y uno de granja, o al revés.
  farmOrWild,

  /// Reto máximo: vehículos de tierra y uno de aire.
  landOrAir,
}

/// Un nivel: cuántos objetos hay en cada tablero.
final class OddLevel {
  const OddLevel({required this.number, required this.objects});

  final int number;
  final int objects;
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
  const OddBoard({required this.objects, required this.oddIndex, required this.kind});

  final List<String> objects;
  final int oddIndex;
  final OddKind kind;

  String get odd => objects[oddIndex];
}

abstract final class OddOneOut {
  static const List<OddLevel> levels = [
    OddLevel(number: 1, objects: 3),
    OddLevel(number: 2, objects: 4),
    OddLevel(number: 3, objects: 4),
    OddLevel(number: 4, objects: 5),
    OddLevel(number: 5, objects: 6),
  ];

  /// Qué compara cada nivel en cada ronda (sección 13): el número de objetos
  /// sube con el nivel; el tipo de comparación, con la ronda.
  static const Map<GameDifficulty, List<OddKind>> kinds = {
    GameDifficulty.easy: [OddKind.identical, OddKind.identical, OddKind.colour, OddKind.colour, OddKind.colour],
    GameDifficulty.normal: [
      OddKind.veryDifferent,
      OddKind.veryDifferent,
      OddKind.veryDifferent,
      OddKind.veryDifferent,
      OddKind.veryDifferent,
    ],
    GameDifficulty.impossible: [
      OddKind.farmOrWild,
      OddKind.farmOrWild,
      OddKind.landOrAir,
      OddKind.farmOrWild,
      OddKind.landOrAir,
    ],
  };

  static OddKind kindFor(GameDifficulty round, int level) => kinds[round]![levelAt(level).number - 1];

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
    OddGroup(id: 'wild', family: 'animals', symbols: ['🦁', '🐯', '🐘', '🦒', '🐵', '🐊']),
    OddGroup(id: 'water', family: 'animals', symbols: ['🐟', '🐳', '🐙', '🐢', '🦀']),
    OddGroup(id: 'fruits', family: 'food', symbols: ['🍎', '🍌', '🍐', '🍇', '🍓', '🍉', '🍒']),
    OddGroup(id: 'land', family: 'vehicles', symbols: ['🚗', '🚌', '🚲', '🚂', '🚜', '🚒']),
    OddGroup(id: 'air', family: 'vehicles', symbols: ['✈️', '🚁', '🚀']),
    OddGroup(id: 'clothes', family: 'clothes', symbols: ['👕', '👖', '👗', '👟', '🎩', '👒']),
    OddGroup(id: 'toys', family: 'toys', symbols: ['⚽', '🏀', '🎈', '🎁']),
    // Colores (Fácil): comida del mismo color.
    OddGroup(id: 'reds', family: 'colours', symbols: ['🍎', '🍓', '🍒', '🍅', '🌶️']),
    OddGroup(id: 'yellows', family: 'colours', symbols: ['🍌', '🍋', '🍍', '🌽']),
    OddGroup(id: 'greens', family: 'colours', symbols: ['🍏', '🥝', '🍐', '🥑', '🥒']),
  ];

  static OddGroup group(String id) => groups.firstWhere((group) => group.id == id);

  static List<OddGroup> _byFamily(bool Function(String family) test) =>
      groups.where((group) => test(group.family)).toList();

  /// Reparte un tablero del [level] en la [round]: N−1 objetos de un grupo y
  /// uno de otro, en una posición al azar (R2).
  static OddBoard board(Random random, OddLevel level, GameDifficulty round) {
    final OddKind kind = kindFor(round, level.number);
    final int many = level.objects - 1;
    final (List<String> same, OddGroup odd) = switch (kind) {
      OddKind.identical => _identical(random, many),
      OddKind.colour => _colour(random, many),
      OddKind.veryDifferent => _differentFamilies(random, many),
      OddKind.farmOrWild => random.nextBool()
          ? (_take(random, group('wild'), many), group('farm'))
          : (_take(random, group('farm'), many), group('wild')),
      OddKind.landOrAir => (_take(random, group('land'), many), group('air')),
    };
    final List<String> others = odd.symbols.where((symbol) => !same.contains(symbol)).toList();
    final String different = others[random.nextInt(others.length)];
    final int oddIndex = random.nextInt(level.objects);
    return OddBoard(objects: [...same]..insert(oddIndex, different), oddIndex: oddIndex, kind: kind);
  }

  static List<String> _take(Random random, OddGroup group, int count) =>
      (List.of(group.symbols)..shuffle(random)).take(count).toList();

  /// La misma figura repetida y una de otra familia.
  static (List<String>, OddGroup) _identical(Random random, int count) {
    final List<OddGroup> shapes = _byFamily((family) => family != 'colours');
    final OddGroup from = shapes[random.nextInt(shapes.length)];
    final String symbol = from.symbols[random.nextInt(from.symbols.length)];
    final List<OddGroup> others = shapes.where((group) => group.family != from.family).toList();
    return (List.filled(count, symbol), others[random.nextInt(others.length)]);
  }

  /// Comida de un color y una de otro color.
  static (List<String>, OddGroup) _colour(Random random, int count) {
    final List<OddGroup> colours =
        _byFamily((family) => family == 'colours').where((group) => group.symbols.length >= count).toList();
    final OddGroup from = colours[random.nextInt(colours.length)];
    final List<OddGroup> others = _byFamily((family) => family == 'colours').where((group) => group != from).toList();
    return (_take(random, from, count), others[random.nextInt(others.length)]);
  }

  /// Dos grupos de familias distintas; el de la mayoría tiene objetos de sobra.
  static (List<String>, OddGroup) _differentFamilies(Random random, int count) {
    final List<OddGroup> candidates =
        _byFamily((family) => family != 'colours').where((group) => group.symbols.length >= count).toList();
    final OddGroup many = candidates[random.nextInt(candidates.length)];
    final List<OddGroup> others =
        _byFamily((family) => family != 'colours' && family != many.family).toList();
    return (_take(random, many, count), others[random.nextInt(others.length)]);
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
