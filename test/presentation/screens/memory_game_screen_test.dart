import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_game_cubit.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';
import '../memory_game_test_support.dart';

void main() {
  setUpAll(() {
    registerMemoryGameFallbacks();
  });

  group('MemoryGameScreen', () {
    late MockPersistenceRepository repository;
    late MemoryGameCubit cubit;

    setUp(() {
      repository = MockPersistenceRepository();
      stubPersistenceRepository(repository);

      cubit = MemoryGameCubit(
        persistenceRepository: repository,
        levelId: 'memory_level_test',
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MemoryGameScreen(
            persistenceRepository: repository,
            levelId: 'memory_level_test',
            imageAssets: const ['🐶'],
            cubit: cubit,
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

      expect(cubit.state.moves, 0);
      expect(cubit.state.firstSelectedCardIndex, isNull);

      await tester.tap(find.byKey(const ValueKey<String>('memory-card-0')));
      await tester.pump();

      expect(cubit.state.firstSelectedCardIndex, 0);
      expect(cubit.state.cards[0].isFaceUp, isTrue);
      expect(cubit.state.moves, 0);

      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('🐶'), findsOneWidget);
      expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
    });

    testWidgets('emits victory dialog when the game is completed', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey<String>('memory-card-0')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey<String>('memory-card-1')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(cubit.state.isCompleted, isTrue);
      expect(find.text('¡Ganaste!'), findsOneWidget);
      expect(find.text('Encontraste todas las parejas.'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.textContaining('Completado en 1 movimientos'), findsOneWidget);
    });
  });
}
