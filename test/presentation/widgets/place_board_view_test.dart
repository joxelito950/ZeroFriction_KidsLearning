import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/shadows/shadow_drop.dart';
import 'package:toddler_logic/presentation/widgets/place_board_view.dart';

/// El tablero de destinos común (HU-027 entrega 1): lo que «Clasificar»
/// necesita además de «A su sitio» — 3 huecos por cesta, piezas de tamaños
/// distintos y cestas de tamaños distintos. «A su sitio» lo cubre su propia
/// batería de tests.
void main() {
  const List<BoardTarget> baskets = [
    BoardTarget(id: 'big', symbol: '🐻', semanticLabel: 'Big'),
    BoardTarget(id: 'medium', symbol: '🐻', semanticLabel: 'Medium', scale: 0.85),
    BoardTarget(id: 'small', symbol: '🐻', semanticLabel: 'Small', scale: 0.7),
  ];

  group('PlaceBoardGeometry', () {
    PlaceBoardGeometry compute({int slots = 3, Size size = const Size(400, 700)}) => PlaceBoardGeometry.compute(
          size: size,
          placesFirst: true,
          targets: baskets,
          pieces: const ['a', 'b', 'c', 'd'],
          devicePixelRatio: 2.6,
          slots: slots,
        );

    test('three slots fit side by side inside the basket, without touching', () {
      final PlaceBoardGeometry geometry = compute();
      for (final BoardTarget basket in baskets) {
        final Rect card = geometry.targetRects[basket.id]!;
        final List<Rect> slots = [for (var i = 0; i < 3; i++) geometry.slotRect(basket.id, i)];
        for (final Rect slot in slots) {
          expect(card.inflate(0.001).contains(slot.topLeft) && card.inflate(0.001).contains(slot.bottomRight), isTrue,
              reason: '${basket.id} keeps its slots inside');
        }
        expect(slots[0].right, lessThan(slots[1].left));
        expect(slots[1].right, lessThan(slots[2].left));
        expect(geometry.slotRect(basket.id, 7), slots[2], reason: 'extra pieces share the last slot');
      }
    });

    test('two slots keep the «A su sitio» layout', () {
      final PlaceBoardGeometry geometry = compute(slots: 2);
      final Rect card = geometry.targetRects['big']!;
      expect(geometry.slotRect('big', 0).width, closeTo(card.width * PlaceBoardGeometry.slotFractionTwo, 1e-9));
      expect(geometry.slotRect('big', 5), geometry.slotRect('big', 1));
    });

    test('a smaller basket shrinks and rests on the bottom of its cell', () {
      final Rect small = compute().targetRects['small']!;
      final Rect cell = PlaceBoardGeometry.compute(
        size: const Size(400, 700),
        placesFirst: true,
        targets: const [
          BoardTarget(id: 'big', symbol: '🐻', semanticLabel: 'Big'),
          BoardTarget(id: 'medium', symbol: '🐻', semanticLabel: 'Medium'),
          BoardTarget(id: 'small', symbol: '🐻', semanticLabel: 'Small'),
        ],
        pieces: const ['a', 'b', 'c', 'd'],
        devicePixelRatio: 2.6,
        slots: 3,
      ).targetRects['small']!;
      expect(small.width, closeTo(cell.width * 0.7, 1e-9));
      expect(small.bottom, closeTo(cell.bottom, 1e-9));
      expect(small.center.dx, closeTo(cell.center.dx, 1e-9));
    });

    test('in landscape with the left hand the baskets move to the other side (HU-031)', () {
      PlaceBoardGeometry landscape({required bool left}) => PlaceBoardGeometry.compute(
            size: const Size(800, 380),
            placesFirst: true,
            targets: baskets,
            pieces: const ['a', 'b'],
            devicePixelRatio: 2.6,
            leftHanded: left,
          );
      expect(landscape(left: false).targetZone.left, 0);
      expect(landscape(left: true).trayZone.left, 0);
    });
  });

  group('PlaceBoardView', () {
    testWidgets('tap a piece, then its basket: it lands in a slot at its own size', (tester) async {
      tester.view.physicalSize = const Size(1080, 2000);
      tester.view.devicePixelRatio = 2.6;
      addTearDown(tester.view.reset);
      final Map<String, String> placed = {};
      final List<String> matches = [];
      const List<BoardPiece> pieces = [
        BoardPiece(id: 'apple-big', symbol: '🍎', semanticLabel: 'Big apple'),
        BoardPiece(id: 'apple-small', symbol: '🍎', semanticLabel: 'Small apple', scale: 0.45),
      ];
      const Map<String, String> answer = {'apple-big': 'big', 'apple-small': 'small'};

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => PlaceBoardView(
              keyPrefix: 'sort',
              data: PlaceBoardData(
                boardId: 1,
                pieces: pieces,
                targets: baskets,
                targetOf: (piece) => answer[piece]!,
                placedAt: (target) => [
                  for (final BoardPiece piece in pieces)
                    if (placed[piece.id] == target) piece.id,
                ],
                isPlaced: placed.containsKey,
                canDrag: (piece) => !placed.containsKey(piece),
                coverageToSnap: 0.5,
                placesFirst: true,
                slots: 3,
              ),
              onGrab: (_) {},
              onDrop: (piece, box, targets) => ShadowDropOutcome.missed,
              onMatch: (piece, target) {
                matches.add('$piece→$target');
                if (answer[piece] != target) return ShadowDropOutcome.wrongShadow;
                setState(() => placed[piece] = target);
                return ShadowDropOutcome.snapped;
              },
            ),
          ),
        ),
      ));

      double fontOf(Finder finder) =>
          tester.widget<Text>(find.descendant(of: finder, matching: find.byType(Text))).style!.fontSize!;
      final double bigInTray = fontOf(find.byKey(const ValueKey<String>('sort-tray-apple-big')));
      final double smallInTray = fontOf(find.byKey(const ValueKey<String>('sort-tray-apple-small')));
      expect(smallInTray, closeTo(bigInTray * 0.45, 1e-6), reason: 'the size is the data (HU-027 3.4)');

      // Una cesta equivocada: vuelve a la bandeja.
      await tester.tap(find.byKey(const ValueKey<String>('sort-tray-apple-small')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('sort-place-big')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey<String>('sort-tray-apple-small')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('sort-tray-apple-small')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('sort-place-small')));
      await tester.pumpAndSettle();
      expect(matches, ['apple-small→big', 'apple-small→small']);
      expect(find.byKey(const ValueKey<String>('sort-tray-apple-small')), findsNothing);
      final Finder inBasket = find.byKey(const ValueKey<String>('sort-placed-apple-small'));
      expect(inBasket, findsOneWidget);
      expect(
          tester.getRect(find.byKey(const ValueKey<String>('sort-place-small'))).contains(tester.getCenter(inBasket)),
          isTrue);
    });
  });
}
