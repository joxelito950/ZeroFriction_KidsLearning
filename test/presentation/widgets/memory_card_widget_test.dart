import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_card_model.dart';
import 'package:toddler_logic/presentation/widgets/memory_card_widget.dart';

import '../l10n_test_support.dart';

void main() {
  testWidgets('shows the back face when the card is hidden', (tester) async {
    const card = MemoryCard(id: 7, assetPath: '🐻');

    await tester.pumpWidget(
      localizedApp(
        home: Scaffold(
          body: Center(
            child: MemoryCardWidget(
              card: card,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('memory-card-button-7')), findsOneWidget);
    expect(find.byKey(const ValueKey<int>(7)), findsOneWidget);
    expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
    expect(find.text('🐻'), findsNothing);
  });

  testWidgets('shows the front face when the card is revealed', (tester) async {
    const card = MemoryCard(id: 8, assetPath: '🐻', isFaceUp: true);

    await tester.pumpWidget(
      localizedApp(
        home: Scaffold(
          body: Center(
            child: MemoryCardWidget(
              card: card,
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const ValueKey<String>('memory-card-front-🐻')), findsOneWidget);
    expect(find.text('🐻'), findsOneWidget);
    expect(find.byIcon(Icons.question_mark_rounded), findsNothing);
  });

  // TD-007 A4, criterio 4: el símbolo es un dibujo y no sigue el texto ampliado.
  group('symbol size', () {
    Future<Size> pumpSymbol(WidgetTester tester, {required double textScale, required double cardSize}) async {
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        localizedApp(
          home: Scaffold(
            body: Center(
              child: SizedBox.square(
                dimension: cardSize,
                child: MemoryCardWidget(card: const MemoryCard(id: 9, assetPath: '🐻', isFaceUp: true), onTap: () {}),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      return tester.getSize(find.byKey(const ValueKey<String>('memory-card-symbol-🐻')));
    }

    testWidgets('does not grow with the system text scale', (tester) async {
      final Size normal = await pumpSymbol(tester, textScale: 1, cardSize: 160);
      final Size large = await pumpSymbol(tester, textScale: 2, cardSize: 160);

      expect(large, normal);
    });

    testWidgets('shrinks on cards too small for it', (tester) async {
      final Size big = await pumpSymbol(tester, textScale: 1, cardSize: 160);
      final Size small = await pumpSymbol(tester, textScale: 1, cardSize: 60);

      expect(small.height, lessThan(big.height));
      expect(small.height, lessThanOrEqualTo(60));
    });
  });
}
