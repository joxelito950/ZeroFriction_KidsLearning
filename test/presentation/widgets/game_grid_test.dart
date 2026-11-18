import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/widgets/game_catalog.dart';
import 'package:toddler_logic/presentation/widgets/game_grid.dart';

/// HU-023: la cuadrícula del menú.
void main() {
  group('GridFit', () {
    test('portrait: 3 games in 2 columns, two above and one below (section 7)', () {
      final GridFit fit = GridFit.best(count: 3, width: 460, height: 500, minColumns: 2);
      expect(fit.columns, 2);
      expect(fit.side, GridFit.maxSide);
    });

    test('landscape: the three games side by side in a low space', () {
      final GridFit fit = GridFit.best(count: 3, width: 370, height: 220);
      expect(fit.columns, 3);
      expect(fit.side, closeTo((370 - 2 * GridFit.spacing) / 3, 0.01));
      expect(fit.fits, isTrue);
    });

    test('up to 6 games fit without scrolling on the compact phone (R2)', () {
      // Compacto en horizontal: la mitad derecha, menos la salida y la Zona de Padres.
      expect(GridFit.best(count: 6, width: 370, height: 220).fits, isTrue);
      // Compacto en vertical, debajo del logo.
      expect(GridFit.best(count: 6, width: 363, height: 480, minColumns: 2).fits, isTrue);
    });

    test('with the same size, fewer columns', () {
      expect(GridFit.best(count: 2, width: 1000, height: 1000).columns, 1);
    });

    test('rejects an empty grid', () {
      expect(() => GridFit.best(count: 0, width: 100, height: 100), throwsRangeError);
    });
  });

  testWidgets('when cards would be too small, the grid scrolls instead (R2, safety net)', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: 300,
          height: 150,
          child: GameGrid(
            count: 6,
            cardBuilder: (context, index, side) => ColoredBox(key: ValueKey<int>(index), color: Colors.teal),
          ),
        ),
      ),
    ));
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.getSize(find.byKey(const ValueKey<int>(0))).width, GridFit.minSide);
  });

  test('the catalog keeps the arrival order, without repeated games (R3, R6)', () {
    final ids = GameCatalog.all.map((game) => game.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(GameCatalog.all.map((game) => game.keyName), ['memory', 'shadows', 'odd-one-out']);
  });
}
