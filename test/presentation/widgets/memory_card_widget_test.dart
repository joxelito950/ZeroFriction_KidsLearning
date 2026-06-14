import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_card_model.dart';
import 'package:toddler_logic/presentation/widgets/memory_card_widget.dart';

void main() {
  testWidgets('shows the back face when the card is hidden', (tester) async {
    const card = MemoryCard(id: 7, assetPath: '🐻');

    await tester.pumpWidget(
      MaterialApp(
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
      MaterialApp(
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
}
