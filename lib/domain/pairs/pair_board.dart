/// Motor de parejas a la vista (HU-036 entrega 1; lo comparte HU-026): cartas
/// boca arriba; se toca una y después su pareja. El contenido de cada carta (un
/// emoji en «Opuestos», un grupo de objetos en «¿Cuántos hay?») lo pone el
/// juego; aquí solo hay cartas, parejas y las reglas de los toques.
library;

import 'dart:math';

/// Cómo van las cartas en el tablero (HU-036 3.1).
enum PairLayout {
  /// Dos columnas (en horizontal, dos filas): a un lado, una carta de cada
  /// pareja; al otro, sus parejas desordenadas. Solo se busca en el otro lado.
  columns,

  /// Todas mezcladas en la cuadrícula.
  mixed,
}

/// Una carta del tablero. [pairId] es la pareja a la que pertenece; `null`, una
/// carta sin pareja (HU-036 P5). [side] es su lado con [PairLayout.columns]
/// (0 o 1); con [PairLayout.mixed] no cuenta.
final class PairCard<T> {
  const PairCard({required this.id, required this.content, this.pairId, this.side = 0});

  final String id;
  final T content;
  final String? pairId;
  final int side;

  bool get unpaired => pairId == null;
}

/// Un tablero de parejas a la vista, en el orden en que se pintan.
final class PairBoard<T> {
  PairBoard({required List<PairCard<T>> cards, required this.layout}) : cards = List.unmodifiable(cards) {
    final Set<String> ids = {};
    final Map<String, int> perPair = {};
    for (final PairCard<T> card in cards) {
      if (!ids.add(card.id)) throw ArgumentError.value(card.id, 'cards', 'repeated card id');
      if (card.pairId case final String pair) perPair[pair] = (perPair[pair] ?? 0) + 1;
      if (card.side != 0 && card.side != 1) throw ArgumentError.value(card.side, 'side');
    }
    for (final MapEntry<String, int> entry in perPair.entries) {
      if (entry.value != 2) throw ArgumentError.value(entry.key, 'cards', 'a pair needs exactly two cards');
    }
  }

  /// Reparte [pairs] (cada una, sus dos contenidos) y las cartas [unpaired].
  /// Con [PairLayout.columns], el primero de cada pareja va al lado 0 y el
  /// segundo al lado 1, cada lado desordenado; las cartas sin pareja, al lado 1.
  /// Con [PairLayout.mixed], todo desordenado. Las parejas se llaman `p0`,
  /// `p1`…, en el orden de [pairs].
  factory PairBoard.deal(
    Random random, {
    required List<(T, T)> pairs,
    List<T> unpaired = const [],
    required PairLayout layout,
  }) {
    final List<PairCard<T>> first = [];
    final List<PairCard<T>> second = [];
    for (var index = 0; index < pairs.length; index++) {
      final (T a, T b) = pairs[index];
      first.add(PairCard<T>(id: 'p$index-a', content: a, pairId: 'p$index', side: 0));
      second.add(PairCard<T>(id: 'p$index-b', content: b, pairId: 'p$index', side: 1));
    }
    for (var index = 0; index < unpaired.length; index++) {
      second.add(PairCard<T>(id: 'u$index', content: unpaired[index], side: 1));
    }
    if (layout == PairLayout.columns) {
      return PairBoard<T>(
        cards: [...(first..shuffle(random)), ...(second..shuffle(random))],
        layout: layout,
      );
    }
    return PairBoard<T>(cards: [...first, ...second]..shuffle(random), layout: layout);
  }

  final List<PairCard<T>> cards;
  final PairLayout layout;

  PairCard<T> card(String id) => cards.firstWhere((card) => card.id == id);

  /// Número de parejas (las cartas sin pareja no cuentan).
  int get pairs => cards.where((card) => !card.unpaired).length ~/ 2;

  /// Si [a] y [b] son las dos cartas de una pareja, en cualquier orden.
  bool matches(String a, String b) {
    if (a == b) return false;
    final String? pair = card(a).pairId;
    return pair != null && pair == card(b).pairId;
  }

  /// La otra carta de la pareja de [id], o `null` si no tiene.
  String? partnerOf(String id) {
    final String? pair = card(id).pairId;
    if (pair == null) return null;
    return cards.firstWhere((other) => other.pairId == pair && other.id != id).id;
  }

  /// Con [PairLayout.columns], tocar otra carta del mismo lado cambia la
  /// elección en lugar de intentar la pareja (HU-036 3.2).
  bool sameSide(String a, String b) => layout == PairLayout.columns && card(a).side == card(b).side;

  /// El tablero se supera con todas las parejas juntas; las cartas sin pareja
  /// no hace falta tocarlas.
  bool isComplete(Set<String> matched) => cards.every((card) => card.unpaired || matched.contains(card.id));
}

/// Qué pasó con un toque.
enum PairTapOutcome {
  /// Se eligió una carta.
  selected,

  /// Se tocó otra vez la elegida: se suelta.
  released,

  /// Otra carta del mismo lado (dos columnas): pasa a ser la elegida.
  changed,

  /// La segunda carta es su pareja: se juntan.
  matched,

  /// La segunda carta no es su pareja: vaivén, fallo y movimiento.
  missed,

  /// Una carta ya emparejada: no hace nada.
  ignored,
}

/// La jugada en curso de un tablero: la carta elegida, las emparejadas, los
/// fallos y los movimientos (cada intento de pareja, HU-039).
final class PairPlay {
  const PairPlay({this.selected, this.matched = const {}, this.fails = 0, this.moves = 0});

  final String? selected;
  final Set<String> matched;
  final int fails;
  final int moves;

  /// El niño toca [id]: devuelve la jugada siguiente y qué pasó.
  (PairPlay, PairTapOutcome) tap<T>(PairBoard<T> board, String id) {
    board.card(id);
    if (matched.contains(id)) return (this, PairTapOutcome.ignored);
    final String? first = selected;
    if (first == null) return (_copy(selected: id), PairTapOutcome.selected);
    if (first == id) return (_copy(), PairTapOutcome.released);
    if (board.sameSide(first, id)) return (_copy(selected: id), PairTapOutcome.changed);
    if (board.matches(first, id)) {
      return (_copy(matched: {...matched, first, id}, moves: moves + 1), PairTapOutcome.matched);
    }
    return (_copy(fails: fails + 1, moves: moves + 1), PairTapOutcome.missed);
  }

  PairPlay _copy({String? selected, Set<String>? matched, int? fails, int? moves}) => PairPlay(
        selected: selected,
        matched: matched ?? this.matched,
        fails: fails ?? this.fails,
        moves: moves ?? this.moves,
      );
}

/// Estrellas de un tablero de parejas (HU-036 4.2), con N parejas: 3★ con
/// N ÷ 2 fallos o menos (redondeando hacia arriba), 2★ hasta N, 1★ con más.
/// Más estricto que «A su sitio» porque aquí se ve todo.
abstract final class PairStars {
  static const int max = 3;

  static int forWin({required int pairs, required int fails}) {
    RangeError.checkNotNegative(fails, 'fails');
    RangeError.checkValueInInterval(pairs, 1, 1000, 'pairs');
    if (fails <= (pairs + 1) ~/ 2) return 3;
    if (fails <= pairs) return 2;
    return 1;
  }
}
