import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/pairs/pair_board.dart';

/// Motor de parejas a la vista (HU-036 entrega 1).
void main() {
  const List<(String, String)> opposites = [('☀️', '🌙'), ('🔥', '❄️'), ('🐘', '🐁')];

  group('PairBoard', () {
    test('deal: two cards per pair; each pair matches in any order, nothing else does', () {
      final PairBoard<String> board = PairBoard.deal(Random(1), pairs: opposites, layout: PairLayout.mixed);
      expect(board.cards, hasLength(6));
      expect(board.pairs, 3);
      for (final PairCard<String> card in board.cards) {
        final String partner = board.partnerOf(card.id)!;
        expect(board.matches(card.id, partner), isTrue);
        expect(board.matches(partner, card.id), isTrue);
        expect(board.matches(card.id, card.id), isFalse);
        for (final PairCard<String> other in board.cards) {
          if (other.id != partner) expect(board.matches(card.id, other.id), isFalse);
        }
      }
      final Map<String, String> contentOf = {for (final card in board.cards) card.id: card.content};
      expect(contentOf[board.partnerOf('p0-a')], '🌙');
    });

    test('two columns: one card of each pair on side 0, its partners shuffled on side 1', () {
      for (var seed = 0; seed < 200; seed++) {
        final PairBoard<String> board = PairBoard.deal(Random(seed), pairs: opposites, layout: PairLayout.columns);
        final List<PairCard<String>> first = board.cards.take(3).toList();
        final List<PairCard<String>> second = board.cards.skip(3).toList();
        expect(first.every((card) => card.side == 0), isTrue);
        expect(second.every((card) => card.side == 1), isTrue);
        expect({for (final card in first) card.content}, {'☀️', '🔥', '🐘'});
        expect(board.sameSide(first[0].id, first[1].id), isTrue);
        expect(board.sameSide(first[0].id, second[0].id), isFalse);
      }
    });

    test('mixed: sides never matter, and the order changes with the seed', () {
      final Set<String> orders = {};
      for (var seed = 0; seed < 30; seed++) {
        final PairBoard<String> board = PairBoard.deal(Random(seed), pairs: opposites, layout: PairLayout.mixed);
        expect(board.sameSide('p0-a', 'p1-a'), isFalse);
        orders.add(board.cards.map((card) => card.id).join());
      }
      expect(orders.length, greaterThan(10));
    });

    test('an unpaired card matches nothing and is not needed to complete the board (P5)', () {
      final PairBoard<String> board =
          PairBoard.deal(Random(3), pairs: opposites.take(2).toList(), unpaired: ['🐇'], layout: PairLayout.mixed);
      expect(board.pairs, 2);
      expect(board.partnerOf('u0'), isNull);
      for (final PairCard<String> card in board.cards) {
        expect(board.matches('u0', card.id), isFalse);
      }
      expect(board.isComplete({'p0-a', 'p0-b', 'p1-a'}), isFalse);
      expect(board.isComplete({'p0-a', 'p0-b', 'p1-a', 'p1-b'}), isTrue);
    });

    test('a pair with one or three cards, or a repeated id, is not a board', () {
      expect(
        () => PairBoard<String>(cards: const [PairCard(id: 'a', content: 'x', pairId: 'p')], layout: PairLayout.mixed),
        throwsArgumentError,
      );
      expect(
        () => PairBoard<String>(
          cards: const [PairCard(id: 'a', content: 'x'), PairCard(id: 'a', content: 'y')],
          layout: PairLayout.mixed,
        ),
        throwsArgumentError,
      );
    });
  });

  group('PairPlay.tap (3.2)', () {
    final PairBoard<String> mixed =
        PairBoard.deal(Random(5), pairs: opposites, unpaired: ['🐇'], layout: PairLayout.mixed);
    final PairBoard<String> columns = PairBoard.deal(Random(5), pairs: opposites, layout: PairLayout.columns);

    test('select, then the partner: they match and count as a move, in any order', () {
      var (PairPlay play, PairTapOutcome outcome) = const PairPlay().tap(mixed, 'p0-b');
      expect(outcome, PairTapOutcome.selected);
      expect(play.selected, 'p0-b');
      (play, outcome) = play.tap(mixed, 'p0-a');
      expect(outcome, PairTapOutcome.matched);
      expect(play.selected, isNull);
      expect(play.matched, {'p0-a', 'p0-b'});
      expect((play.moves, play.fails), (1, 0));
      expect(play.tap(mixed, 'p0-a').$2, PairTapOutcome.ignored, reason: 'a matched card does nothing');
    });

    test('tapping the selected card again releases it, without a move', () {
      final (PairPlay play, _) = const PairPlay().tap(mixed, 'p1-a');
      final (PairPlay released, PairTapOutcome outcome) = play.tap(mixed, 'p1-a');
      expect(outcome, PairTapOutcome.released);
      expect(released.selected, isNull);
      expect(released.moves, 0);
    });

    test('a wrong second card is a miss: a fail and a move, and the selection is dropped', () {
      final (PairPlay play, _) = const PairPlay().tap(mixed, 'p0-a');
      final (PairPlay next, PairTapOutcome outcome) = play.tap(mixed, 'p1-b');
      expect(outcome, PairTapOutcome.missed);
      expect((next.fails, next.moves, next.selected), (1, 1, null));
      expect(next.matched, isEmpty);
      expect(next.tap(mixed, 'u0').$1.tap(mixed, 'p2-a').$2, PairTapOutcome.missed,
          reason: 'an unpaired card and another one is a miss');
    });

    test('in two columns, another card on the same side changes the selection (no move)', () {
      final String a = columns.cards[0].id;
      final String b = columns.cards[1].id;
      final (PairPlay play, _) = const PairPlay().tap(columns, a);
      final (PairPlay next, PairTapOutcome outcome) = play.tap(columns, b);
      expect(outcome, PairTapOutcome.changed);
      expect((next.selected, next.moves), (b, 0));
      expect(next.tap(columns, columns.partnerOf(b)!).$2, PairTapOutcome.matched);
    });
  });

  group('PairStars (4.2)', () {
    test('3 stars up to half the pairs (rounded up), 2 up to the pairs, then 1', () {
      expect(PairStars.forWin(pairs: 6, fails: 3), 3);
      expect(PairStars.forWin(pairs: 6, fails: 4), 2);
      expect(PairStars.forWin(pairs: 6, fails: 6), 2);
      expect(PairStars.forWin(pairs: 6, fails: 7), 1);
      expect(PairStars.forWin(pairs: 5, fails: 3), 3, reason: '5 ÷ 2 rounded up');
      expect(PairStars.forWin(pairs: 2, fails: 1), 3);
      expect(PairStars.forWin(pairs: 2, fails: 2), 2);
      expect(PairStars.forWin(pairs: 2, fails: 30), 1);
    });
  });
}
