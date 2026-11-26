import 'dart:math';

import 'sort_catalog.dart';
import 'sort_ladder.dart';

/// Una pieza de la bandeja: un objeto en un tamaño. Un mismo objeto puede
/// salir varias veces (🍓 🍓 en el tutorial, 🐶 grande y 🐶 pequeño), así que
/// cada pieza lleva su propio [id].
final class SortPiece {
  const SortPiece({required this.id, required this.object, this.size = SortSize.big});

  final String id;
  final SortObject object;
  final SortSize size;

  SortColor? get color => object.color;

  @override
  bool operator ==(Object other) =>
      other is SortPiece && other.id == id && other.object == object && other.size == size;

  @override
  int get hashCode => Object.hash(id, object, size);

  @override
  String toString() => 'SortPiece($id, ${object.name}, ${size.name})';
}

/// Una cesta: un color, un tamaño o las dos cosas. Su [sample] dice qué va
/// dentro, y la tarjeta tiene el tamaño de la cesta (P6).
final class SortBasket {
  const SortBasket({this.color, this.size, required this.sample})
      : assert(color != null || size != null, 'a basket sorts by colour, by size or both');

  final SortColor? color;
  final SortSize? size;
  final SortObject sample;

  /// `red`, `big` o `red-big`: la clave de su tarjeta.
  String get id => [color?.name, size?.name].nonNulls.join('-');

  bool accepts(SortPiece piece) => (color == null || piece.color == color) && (size == null || piece.size == size);

  @override
  bool operator ==(Object other) =>
      other is SortBasket && other.color == color && other.size == size && other.sample == sample;

  @override
  int get hashCode => Object.hash(color, size, sample);

  @override
  String toString() => 'SortBasket($id)';
}

/// Un tablero de «Clasificar» (HU-027 3.1): las cestas, arriba, y los objetos
/// de la bandeja. Cada objeto tiene una sola cesta correcta, y una cesta
/// recibe como mucho [SortLadder.maxPerBasket].
final class SortBoard {
  SortBoard({
    required this.criterion,
    required List<SortBasket> baskets,
    required List<SortPiece> pieces,
    this.trayCapacity,
  })  : baskets = List.unmodifiable(baskets),
        pieces = List.unmodifiable(pieces) {
    if (baskets.map((basket) => basket.id).toSet().length != baskets.length) {
      throw ArgumentError.value(baskets, 'baskets', 'repeated basket');
    }
    if (pieces.map((piece) => piece.id).toSet().length != pieces.length) {
      throw ArgumentError.value(pieces, 'pieces', 'repeated id');
    }
    for (final SortPiece piece in pieces) {
      if (baskets.where((basket) => basket.accepts(piece)).length != 1) {
        throw ArgumentError.value(piece, 'pieces', 'needs exactly one right basket');
      }
    }
    for (final SortBasket basket in baskets) {
      if (pieces.where(basket.accepts).length > SortLadder.maxPerBasket) {
        throw ArgumentError.value(basket, 'baskets', 'more than ${SortLadder.maxPerBasket} objects');
      }
    }
  }

  final SortCriterion criterion;

  /// Las cestas en el orden en que se muestran.
  final List<SortBasket> baskets;

  /// Los objetos en el orden de la bandeja (o en el que van entrando).
  final List<SortPiece> pieces;

  /// Objetos a la vista a la vez cuando la bandeja se repone (4.3); `null`,
  /// todos.
  final int? trayCapacity;

  SortBasket targetOf(SortPiece piece) => baskets.firstWhere((basket) => basket.accepts(piece));

  /// ¿Va [piece] en [basket]? Si no, vuelve a la bandeja y cuenta como fallo.
  bool accepts(SortBasket basket, SortPiece piece) => basket.accepts(piece);

  SortPiece pieceById(String id) => pieces.firstWhere((piece) => piece.id == id);

  SortBasket basketById(String id) => baskets.firstWhere((basket) => basket.id == id);

  /// Cestas que no reciben ningún objeto.
  List<SortBasket> get freeBaskets => [
        for (final SortBasket basket in baskets)
          if (!pieces.any(basket.accepts)) basket,
      ];

  /// Sortea el tablero de [level] con las reglas de la ronda.
  static SortBoard pick(Random random, SortLevel level, SortRules rules) => switch (rules.criterion) {
        SortCriterion.color => _pickColor(random, level, rules),
        SortCriterion.size => _pickSize(random, level, rules),
        SortCriterion.colorAndSize => _pickColorAndSize(random, level, rules),
      };

  /// Reparte [total] objetos entre [keys]: al menos [minimum] en cada una y
  /// como mucho lo que diga [capacity].
  static Map<K, int> _spread<K>(Random random, List<K> keys, int total, int Function(K key) capacity,
      {int minimum = 1}) {
    final Map<K, int> counts = {for (final K key in keys) key: minimum};
    for (var left = total - keys.length * minimum; left > 0; left--) {
      final List<K> open = [
        for (final K key in keys)
          if (counts[key]! < capacity(key)) key,
      ];
      final K key = open[random.nextInt(open.length)];
      counts[key] = counts[key]! + 1;
    }
    return counts;
  }

  /// Dos colores que no sean solo rojo y verde.
  static List<SortColor> _twoColors(Random random, List<SortColor> colors) {
    while (true) {
      final List<SortColor> chosen = ([...colors]..shuffle(random)).take(2).toList();
      if (!SortColor.confusable(chosen.toSet())) return chosen;
    }
  }

  /// Por color (5.1):
  /// 1. Los colores de las cestas con objetos, nunca solo rojo y verde.
  /// 2. Cuántos objetos van a cada cesta: al menos 1 y como mucho 3 (o los que
  ///    tenga ese color).
  /// 3. Los objetos: la muestra repetida en los niveles con ayuda; si no,
  ///    objetos distintos de su color, sin la muestra.
  /// 4. La cesta libre, si toca, y el orden al azar.
  static SortBoard _pickColor(Random random, SortLevel level, SortRules rules) {
    final bool sampleInTray = rules.sampleInTray;
    final bool withFree = rules.freeBaskets && level.freeBasket;
    int capacity(SortColor color) => sampleInTray
        ? SortLadder.maxPerBasket
        : min(SortLadder.maxPerBasket, SortCatalog.objectsOf(color, withSample: false).length);

    for (var attempt = 0; attempt < 100; attempt++) {
      final List<SortColor> chosen = ([...rules.colors]..shuffle(random)).take(level.baskets).toList();
      if (SortColor.confusable(chosen.toSet())) continue;
      if (chosen.fold(0, (sum, color) => sum + capacity(color)) < level.objects) continue;
      final Map<SortColor, int> counts = _spread(random, chosen, level.objects, capacity);

      final List<SortPiece> pieces = [];
      for (final SortColor color in chosen) {
        final List<SortObject> objects = sampleInTray
            ? List.filled(counts[color]!, color.sample)
            : (SortCatalog.objectsOf(color, withSample: false)..shuffle(random)).take(counts[color]!).toList();
        for (final SortObject object in objects) {
          pieces.add(SortPiece(id: '${object.name}-${pieces.length}', object: object));
        }
      }

      final List<SortColor> colors = [...chosen];
      if (withFree) {
        final List<SortColor> spare = [
          for (final SortColor color in rules.colors)
            if (!chosen.contains(color)) color,
        ];
        if (spare.isNotEmpty) colors.add(spare[random.nextInt(spare.length)]);
      }
      return SortBoard(
        criterion: SortCriterion.color,
        baskets: [for (final SortColor color in colors) SortBasket(color: color, sample: color.sample)]
          ..shuffle(random),
        pieces: pieces..shuffle(random),
      );
    }
    throw StateError('Could not pick a board for level ${level.number}');
  }

  /// Por tamaño (5.2): una temática al azar; las cestas, con su muestra en
  /// cada tamaño; en la bandeja, uno o dos emojis de la temática, cada uno en
  /// todos los tamaños que quepan. Las cestas van de mayor a menor.
  static SortBoard _pickSize(Random random, SortLevel level, SortRules rules) {
    final List<SortSize> sizes = rules.sizes;
    final int total = min(level.objects, sizes.length * SortLadder.maxPerBasket);
    final SortTheme theme = SortTheme.values[random.nextInt(SortTheme.values.length)];
    final List<SortObject> objects = ([...theme.objects]..shuffle(random)).take(rules.sizeObjects).toList();
    final int minimum = max(1, min(objects.length, total ~/ sizes.length));

    // Cada emoji sale en al menos dos tamaños: así se compara la misma cosa.
    for (var attempt = 0; attempt < 50; attempt++) {
      final Map<SortSize, int> counts =
          _spread(random, sizes, total, (_) => SortLadder.maxPerBasket, minimum: minimum);
      final List<SortPiece> pieces = [];
      for (final (int index, SortSize size) in sizes.indexed) {
        for (var i = 0; i < counts[size]!; i++) {
          final SortObject object = objects[(index + i) % objects.length];
          pieces.add(SortPiece(id: '${object.name}-${size.name}-${pieces.length}', object: object, size: size));
        }
      }
      // Con muy pocos objetos (un nivel 1 fuera de bronce), basta con que salgan.
      final int needed = total >= 2 * objects.length ? 2 : 1;
      final bool compared = objects.every((object) =>
          pieces.where((piece) => piece.object == object).map((piece) => piece.size).toSet().length >= needed);
      if (!compared) continue;
      return SortBoard(
        criterion: SortCriterion.size,
        baskets: [for (final SortSize size in sizes) SortBasket(size: size, sample: theme.sample)],
        pieces: pieces..shuffle(random),
      );
    }
    throw StateError('Could not pick a size board for level ${level.number}');
  }

  /// Color y tamaño a la vez (P5, 5.2): 2 colores × los tamaños del nivel. La
  /// muestra de cada cesta es la de su color en su tamaño, y no está en la
  /// bandeja; en la bandeja, uno o dos objetos de cada color en esos tamaños.
  /// En el nivel 8 de diamante, la bandeja se repone (4.3).
  static SortBoard _pickColorAndSize(Random random, SortLevel level, SortRules rules) {
    final List<SortColor> colors = _twoColors(random, rules.colors);
    final List<SortSize> sizes = rules.sizes;
    final List<SortBasket> baskets = [
      for (final SortColor color in colors)
        for (final SortSize size in sizes) SortBasket(color: color, size: size, sample: color.sample),
    ];
    final int total = rules.refill
        ? SortRules.refillTotal
        : min(max(level.objects, baskets.length), baskets.length * SortLadder.maxPerBasket);
    final Map<SortColor, List<SortObject>> objects = {
      for (final SortColor color in colors)
        color: (SortCatalog.objectsOf(color, withSample: false)..shuffle(random)).take(2).toList(),
    };
    final Map<SortBasket, int> counts = _spread(random, baskets, total, (_) => SortLadder.maxPerBasket);

    final List<SortPiece> pieces = [];
    for (final SortBasket basket in baskets) {
      final List<SortObject> mine = objects[basket.color]!;
      for (var i = 0; i < counts[basket]!; i++) {
        final SortObject object = mine[(i + basket.size!.index) % mine.length];
        pieces.add(SortPiece(id: '${object.name}-${basket.size!.name}-${pieces.length}', object: object, size: basket.size!));
      }
    }
    return SortBoard(
      criterion: SortCriterion.colorAndSize,
      baskets: baskets,
      pieces: pieces..shuffle(random),
      trayCapacity: rules.refill ? SortRules.refillVisible : null,
    );
  }
}
