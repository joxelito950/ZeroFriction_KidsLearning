import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';
import '../memory_game_test_support.dart';

void main() {
  setUpAll(() {
    registerMemoryGameFallbacks();
  });

  group('MemoryGameScreen', () {
    late MockPersistenceRepository repository;

    setUp(() {
      repository = MockPersistenceRepository();
      stubPersistenceRepository(repository);
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RepositoryProvider<IPersistenceRepository>.value(
            value: repository,
            child: const MemoryGameScreen(
              levelId: 'memory_level_test',
              emojis: ['🐶'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows cards face down initially', (tester) async {
      await pumpScreen(tester);

      expect(find.byIcon(Icons.question_mark_rounded), findsNWidgets(2));
      expect(find.text('🐶'), findsNothing);
      expect(find.text('¡Ganaste!'), findsNothing);
    });

    testWidgets('tapping a card triggers cubit logic and starts the reveal animation', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey<String>('memory-card-0')));
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('🐶'), findsOneWidget);
      expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
    });

    testWidgets('emits victory dialog when the game is completed', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey<String>('memory-card-0')));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byKey(const ValueKey<String>('memory-card-1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('¡Lo lograste!'), findsOneWidget);
      expect(find.text('Encontraste todas las parejas.'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.textContaining('Completado en 1 movimientos'), findsOneWidget);
    });
  });
}
