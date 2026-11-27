import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/pairs/pair_board.dart';
import 'package:toddler_logic/presentation/widgets/pair_board_view.dart';

/// Vista del motor de parejas a la vista (HU-036 entrega 1).
void main() {
  const List<(String, String)> six = [
    ('☀️', '🌙'),
    ('🔥', '❄️'),
    ('🐘', '🐁'),
    ('😄', '😢'),
    ('🐇', '🐢'),
    ('👴', '👶'),
  ];

  group('PairBoardGeometry', () {
    // Los teléfonos compactos de los tests de diseño (D-011), descontando la
    // cabecera del juego.
    const List<Size> boards = [Size(379, 640), Size(882, 250), Size(328, 520), Size(700, 220)];

    for (final PairLayout layout in PairLayout.values) {
      for (final Size size in boards) {
        test('12 cards (${layout.name}) fit in $size, at least 64 dp each and without touching', () {
          final PairBoard<String> board = PairBoard.deal(Random(1), pairs: six, layout: layout);
          final PairBoardGeometry geometry = PairBoardGeometry.compute(size: size, board: board);
          final Rect area = Offset.zero & size;
          expect(geometry.side, greaterThanOrEqualTo(PairBoardGeometry.minSide));
          final List<Rect> rects = geometry.rects.values.toList();
          expect(rects, hasLength(12));
          for (var i = 0; i < rects.length; i++) {
            expect(area.inflate(0.01).contains(rects[i].topLeft) && area.inflate(0.01).contains(rects[i].bottomRight),
                isTrue,
                reason: '${rects[i]}');
            for (var j = i + 1; j < rects.length; j++) {
              expect(rects[i].intersect(rects[j]).width > 0.01 && rects[i].intersect(rects[j]).height > 0.01, isFalse);
            }
          }
        });
      }
    }

    test('two columns: side 0 in one column, side 1 in the other (in landscape, two rows)', () {
      final PairBoard<String> board =
          PairBoard.deal(Random(2), pairs: six.take(3).toList(), layout: PairLayout.columns);
      final PairBoardGeometry portrait = PairBoardGeometry.compute(size: const Size(380, 640), board: board);
      final PairBoardGeometry landscape = PairBoardGeometry.compute(size: const Size(880, 260), board: board);
      for (final PairCard<String> card in board.cards) {
        final PairCard<String> first = board.cards.firstWhere((other) => other.side == card.side);
        expect(portrait.rects[card.id]!.left, portrait.rects[first.id]!.left);
        expect(landscape.rects[card.id]!.top, landscape.rects[first.id]!.top);
      }
      final Rect a = portrait.rects[board.cards.first.id]!;
      final Rect b = portrait.rects[board.cards.last.id]!;
      expect(b.left - a.right, closeTo(PairBoardGeometry.sideGap, 1e-9));
    });

    test('with few cards they stop growing and stay centred', () {
      final PairBoard<String> board = PairBoard.deal(Random(2), pairs: six.take(2).toList(), layout: PairLayout.mixed);
      final PairBoardGeometry geometry = PairBoardGeometry.compute(size: const Size(800, 800), board: board);
      expect(geometry.side, PairBoardGeometry.maxSide);
      final Rect all = geometry.rects.values.reduce((a, b) => a.expandToInclude(b));
      expect(all.center.dx, closeTo(400, 1e-9));
      expect(all.center.dy, closeTo(400, 1e-9));
    });
  });

  group('PairBoardView', () {
    testWidgets('tap a card and its partner: selected with the amber halo, then both matched and dimmed',
        (tester) async {
      final PairBoard<String> board = PairBoard.deal(Random(4), pairs: six.take(3).toList(), layout: PairLayout.mixed);
      PairPlay play = const PairPlay();
      final List<PairTapOutcome> outcomes = [];
      (String, String)? joined;
      int joinToken = 0;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => PairBoardView<String>(
              keyPrefix: 'pairs',
              board: board,
              play: play,
              joined: joined,
              joinToken: joinToken,
              cardBuilder: (context, card, side) => Text(card.content, style: TextStyle(fontSize: side * 0.6)),
              semanticLabel: (card) => 'Card ${card.content}',
              onTap: (id) {
                final String? first = play.selected;
                final (PairPlay next, PairTapOutcome outcome) = play.tap(board, id);
                outcomes.add(outcome);
                setState(() {
                  play = next;
                  if (outcome == PairTapOutcome.matched) {
                    joined = (first!, id);
                    joinToken++;
                  }
                });
              },
            ),
          ),
        ),
      ));

      Finder cardOf(String id) => find.byKey(ValueKey<String>('pairs-card-$id'));
      // La caja de dentro: la de fuera no se mueve con las animaciones.
      Finder boxOf(String id) => find.descendant(of: cardOf(id), matching: find.byType(AnimatedContainer));
      BoxDecoration decorationOf(String id) => tester
          .widget<AnimatedContainer>(find.descendant(of: cardOf(id), matching: find.byType(AnimatedContainer)))
          .decoration! as BoxDecoration;

      await tester.tap(cardOf('p1-a'));
      await tester.pumpAndSettle();
      expect((decorationOf('p1-a').border! as Border).top.width, 4, reason: 'amber halo');
      final Offset before = tester.getCenter(boxOf('p1-b'));

      await tester.tap(cardOf('p1-b'));
      await tester.pump();
      await tester.pump(PairBoardView.joinDuration ~/ 2);
      expect(tester.getCenter(boxOf('p1-b')), isNot(before), reason: 'they move towards each other');
      await tester.pumpAndSettle();
      expect(tester.getCenter(boxOf('p1-b')), before, reason: 'and stay in place');
      expect(outcomes, [PairTapOutcome.selected, PairTapOutcome.matched]);
      expect(play.matched, {'p1-a', 'p1-b'});
      final AnimatedOpacity dim =
          tester.widget<AnimatedOpacity>(find.descendant(of: cardOf('p1-b'), matching: find.byType(AnimatedOpacity)));
      expect(dim.opacity, 0.6);
    });

    testWidgets('a miss shakes both cards; the screen reader can pick a card', (tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final PairBoard<String> board = PairBoard.deal(Random(4), pairs: six.take(2).toList(), layout: PairLayout.mixed);
      final List<String> taps = [];

      Widget view(int missToken) => MaterialApp(
            home: Scaffold(
              body: PairBoardView<String>(
                keyPrefix: 'pairs',
                board: board,
                play: const PairPlay(),
                missed: missToken == 0 ? null : ('p0-a', 'p1-b'),
                missToken: missToken,
                cardBuilder: (context, card, side) => Text(card.content),
                semanticLabel: (card) => 'Card ${card.content}',
                onTap: taps.add,
              ),
            ),
          );

      await tester.pumpWidget(view(0));
      final Offset still = tester.getCenter(find.descendant(
          of: find.byKey(const ValueKey<String>('pairs-card-p0-a')), matching: find.byType(AnimatedContainer)));
      await tester.pumpWidget(view(1));
      await tester.pump(PairBoardView.shakeDuration ~/ 8);
      expect(
          tester.getCenter(find.descendant(
              of: find.byKey(const ValueKey<String>('pairs-card-p0-a')), matching: find.byType(AnimatedContainer))),
          isNot(still));
      await tester.pumpAndSettle();
      expect(
          tester.getCenter(find.descendant(
              of: find.byKey(const ValueKey<String>('pairs-card-p0-a')), matching: find.byType(AnimatedContainer))),
          still);

      await tester.tap(find.bySemanticsLabel('Card ☀️'));
      expect(taps, ['p0-a']);
      semantics.dispose();
    });
  });
}
