import 'dart:math';

import 'sort_catalog.dart';
import 'sort_ladder.dart';

/// Una pieza de la bandeja. En los niveles con la muestra igual se repite el
/// mismo objeto (🍓 🍓), así que cada pieza lleva su propio [id].
final class SortPiece {
  const SortPiece({required this.id, required this.object});

  final String id;
  final SortObject object;

  SortColor get color => object.color;

  @override
  bool operator ==(Object other) => other is SortPiece && other.id == id && other.object == object;

  @override
  int get hashCode => Object.hash(id, object);

  @override
  String toString() => 'SortPiece($id, ${object.name})';
}

/// Un tablero de «Clasificar» por color (HU-027 3.1): las cestas, arriba, y
/// los objetos de la bandeja. Cada objeto tiene una sola cesta correcta, la de
/// su color, y una cesta recibe como mucho [SortLadder.maxPerBasket].
final class SortBoard {
  SortBoard({required List<SortColor> baskets, required List<SortPiece> pieces})
      : baskets = List.unmodifiable(baskets),
        pieces = List.unmodifiable(pieces) {
    if (baskets.toSet().length != baskets.length) throw ArgumentError.value(baskets, 'baskets', 'repeated colour');
    if (pieces.map((piece) => piece.id).toSet().length != pieces.length) {
      throw ArgumentError.value(pieces, 'pieces', 'repeated id');
    }
    for (final SortPiece piece in pieces) {
      if (!baskets.contains(piece.color)) throw ArgumentError.value(piece, 'pieces', 'its basket is not on the board');
    }
    for (final SortColor basket in baskets) {
      if (pieces.where((piece) => piece.color == basket).length > SortLadder.maxPerBasket) {
        throw ArgumentError.value(basket, 'baskets', 'more than ${SortLadder.maxPerBasket} objects');
      }
    }
  }

  /// Las cestas en el orden en que se muestran.
  final List<SortColor> baskets;

  /// Los objetos en el orden de la bandeja.
  final List<SortPiece> pieces;

  SortColor targetOf(SortPiece piece) => piece.color;

  /// ¿Va [piece] en la cesta [basket]? Si no, vuelve a la bandeja y cuenta
  /// como fallo para las estrellas.
  bool accepts(SortColor basket, SortPiece piece) => piece.color == basket;

  SortPiece pieceById(String id) => pieces.firstWhere((piece) => piece.id == id);

  /// Cestas que no reciben ningún objeto.
  List<SortColor> get freeBaskets => [
        for (final SortColor basket in baskets)
          if (!pieces.any((piece) => piece.color == basket)) basket,
      ];

  /// Sortea el tablero de [level] con las reglas de la ronda:
  ///
  /// 1. Los colores de las cestas con objetos, nunca solo rojo y verde.
  /// 2. Cuántos objetos van a cada cesta: al menos 1 y como mucho 3 (o los que
  ///    tenga ese color).
  /// 3. Los objetos: la muestra repetida en los niveles con ayuda; si no,
  ///    objetos distintos de su color, sin la muestra.
  /// 4. La cesta libre, si toca, y el orden al azar.
  static SortBoard pick(Random random, SortLevel level, SortRules rules) {
    final bool sampleInTray = rules.sampleInTray;
    final bool withFree = rules.freeBaskets && level.freeBasket;
    int capacity(SortColor color) => sampleInTray
        ? SortLadder.maxPerBasket
        : min(SortLadder.maxPerBasket, SortCatalog.objectsOf(color, withSample: false).length);

    for (var attempt = 0; attempt < 100; attempt++) {
      final List<SortColor> colors = [...rules.colors]..shuffle(random);
      final List<SortColor> chosen = colors.take(level.baskets).toList();
      if (SortColor.confusable(chosen.toSet())) continue;
      final int room = chosen.fold(0, (sum, color) => sum + capacity(color));
      if (room < level.objects) continue;

      final Map<SortColor, int> counts = {for (final SortColor color in chosen) color: 1};
      var left = level.objects - chosen.length;
      while (left > 0) {
        final List<SortColor> open = [
          for (final SortColor color in chosen)
            if (counts[color]! < capacity(color)) color,
        ];
        final SortColor color = open[random.nextInt(open.length)];
        counts[color] = counts[color]! + 1;
        left--;
      }

      final List<SortPiece> pieces = [];
      for (final SortColor color in chosen) {
        final List<SortObject> objects = sampleInTray
            ? List.filled(counts[color]!, color.sample)
            : (SortCatalog.objectsOf(color, withSample: false)..shuffle(random)).take(counts[color]!).toList();
        for (final SortObject object in objects) {
          pieces.add(SortPiece(id: '${object.name}-${pieces.length}', object: object));
        }
      }

      final List<SortColor> baskets = [...chosen];
      if (withFree) {
        final List<SortColor> spare = [
          for (final SortColor color in rules.colors)
            if (!chosen.contains(color)) color,
        ];
        if (spare.isNotEmpty) baskets.add(spare[random.nextInt(spare.length)]);
      }
      return SortBoard(baskets: baskets..shuffle(random), pieces: pieces..shuffle(random));
    }
    throw StateError('Could not pick a board for level ${level.number}');
  }
}
