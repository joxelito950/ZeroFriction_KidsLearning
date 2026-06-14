import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/widgets/memory_victory_dialog.dart';

void main() {
  testWidgets('shows celebration copy and three stars', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: MemoryVictoryDialog(moves: 4),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('memory-victory-dialog')), findsOneWidget);
    expect(find.text('¡Ganaste!'), findsOneWidget);
    expect(find.text('Encontraste todas las parejas.'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
    expect(find.text('Completado en 4 movimientos'), findsOneWidget);
    expect(find.text('Seguir jugando'), findsOneWidget);
  });
}
