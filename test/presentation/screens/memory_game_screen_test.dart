import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_cubit.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_state.dart';
import 'package:toddler_logic/presentation/blocs/play_time/play_time_cubit.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';
import 'package:toddler_logic/presentation/widgets/gesture_hint.dart';
import 'package:toddler_logic/presentation/widgets/memory_board.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

/// Abre el juego desde una pantalla previa, para poder comprobar la salida.
class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => MemoryGameScreen(random: Random(7), preview: Duration.zero)),
          ),
          child: const Text('launcher'),
        ),
      ),
    );
  }
}

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

    Future<void> pumpScreen(WidgetTester tester, {int level = 1, Locale locale = testLocale}) async {
      when(() => repository.readMemoryProgress()).thenAnswer((_) async => MemoryProgress(currentLevel: level));
      await tester.pumpWidget(
        RepositoryProvider<IPersistenceRepository>.value(
          value: repository,
          child: localizedApp(locale: locale, home: const _Launcher()),
        ),
      );
      await tester.tap(find.text('launcher'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    MemoryLadderCubit cubitOf(WidgetTester tester) =>
        tester.element(find.byType(MemoryBoard)).read<MemoryLadderCubit>();

    /// Índices de las parejas del tablero en juego.
    List<List<int>> pairsOf(WidgetTester tester) {
      final cards = cubitOf(tester).state.cards;
      final bySymbol = <String, List<int>>{};
      for (var i = 0; i < cards.length; i++) {
        bySymbol.putIfAbsent(cards[i].assetPath, () => []).add(i);
      }
      return bySymbol.values.toList();
    }

    Future<void> tapCard(WidgetTester tester, int index) async {
      await tester.tap(find.byKey(ValueKey<String>('memory-card-$index')));
      await tester.pump(const Duration(milliseconds: 450));
    }

    Future<void> winPerfectly(WidgetTester tester) async {
      for (final pair in pairsOf(tester)) {
        await tapCard(tester, pair[0]);
        await tapCard(tester, pair[1]);
      }
    }

    int cardCount() => find.byType(MemoryBoard).evaluate().isEmpty
        ? 0
        : find.descendant(of: find.byType(MemoryBoard), matching: find.byIcon(Icons.question_mark_rounded))
            .evaluate()
            .length;

    testWidgets('starts at level 1 with 4 face-down cards and no time bar', (tester) async {
      await pumpScreen(tester);

      expect(cardCount(), 4);
      expect(find.byKey(const ValueKey<String>('memory-time-bar')), findsNothing);
      expect(find.byKey(const ValueKey<String>('memory-level-dot-1-reached')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('memory-level-dot-2-pending')), findsOneWidget);
      expect(find.text('Busquemos las parejas iguales.'), findsOneWidget);
      expect(find.bySemanticsLabel('Nivel 1 de 5'), findsOneWidget);
    });

    // HU-009 R4: un tablero tocado, o su celebración, no se corta al llegar al límite diario.
    testWidgets('tells the daily play time when a board is in progress', (tester) async {
      await pumpScreen(tester);
      final PlayTimeCubit playTime = tester.element(find.byType(MemoryBoard)).read<PlayTimeCubit>();
      expect(playTime.state.boardInProgress, isFalse);

      final List<List<int>> pairs = pairsOf(tester);
      await tapCard(tester, pairs[0][0]);
      expect(playTime.state.boardInProgress, isTrue);

      await tapCard(tester, pairs[0][1]);
      await tapCard(tester, pairs[1][0]);
      await tapCard(tester, pairs[1][1]);
      expect(cubitOf(tester).state.phase, MemoryRoundPhase.celebrating);
      expect(playTime.state.boardInProgress, isTrue);

      await tester.pump(MemoryLadderCubit.celebrationDuration);
      await tester.pump(const Duration(milliseconds: 600));
      expect(cubitOf(tester).state.phase, MemoryRoundPhase.playing);
      expect(playTime.state.boardInProgress, isFalse);

      await tapCard(tester, pairsOf(tester)[0][0]);
      expect(playTime.state.boardInProgress, isTrue);
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MemoryBoard), findsNothing);
      expect(playTime.state.boardInProgress, isFalse);
    });

    test('a time-up notice counts as a board in progress; loading does not', () {
      expect(MemoryGameScreen.boardInProgress(const MemoryLadderState(phase: MemoryRoundPhase.timeUp)), isTrue);
      expect(MemoryGameScreen.boardInProgress(const MemoryLadderState()), isFalse);
    });

    // TD-007 A3, A5: con el texto del sistema a 2,0, el juego lo limita a 1,3.
    testWidgets('caps the system text scale for the game texts', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpScreen(tester);

      final TextScaler scaler = MediaQuery.textScalerOf(tester.element(find.text('Busquemos las parejas iguales.')));
      expect(scaler.scale(10), closeTo(10 * MemoryGameScreen.maxTextScale, 0.001));
    });

    // HU-022, criterio 4: la mano toca una carta sin darle la vuelta ni arrancar el tiempo.
    testWidgets('an idle child sees a hand tapping a card, without flipping it or starting the time', (tester) async {
      final hand = find.byKey(const ValueKey<String>('gesture-hint-hand'));
      await pumpScreen(tester, level: 3);
      expect(hand, findsNothing);

      await tester.pump(GestureHint.defaultFirstDelay);
      await tester.pump(GestureHint.cycle * 0.6);

      expect(hand, findsOneWidget);
      expect(cardCount(), 8, reason: 'every card stays face down');
      expect(cubitOf(tester).state.remainingFraction, 1, reason: 'the time bar has not started');

      await tapCard(tester, 0);
      await tester.pump(const Duration(seconds: 20));
      expect(hand, findsNothing, reason: 'it does not come back once the child plays');
    });

    testWidgets('resumes the saved level with its arrival time limit', (tester) async {
      await pumpScreen(tester, level: 3);

      expect(cardCount(), 8);
      expect(find.byKey(const ValueKey<String>('memory-time-bar')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('memory-level-dot-3-reached')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('memory-level-dot-4-pending')), findsOneWidget);
    });

    testWidgets('a mismatch shows the processing hint and hides the cards again', (tester) async {
      await pumpScreen(tester);
      final pairs = pairsOf(tester);

      await tapCard(tester, pairs[0][0]);
      await tapCard(tester, pairs[1][0]);
      expect(find.text('Mira bien… las cartas se dan la vuelta.'), findsOneWidget);

      await tester.pump(MemoryLadderCubit.mismatchDelay);
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.text('Busquemos las parejas iguales.'), findsOneWidget);
      expect(cardCount(), 4);
    });

    testWidgets('winning celebrates with stars and deals the next level by itself', (tester) async {
      await pumpScreen(tester);

      await winPerfectly(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey<String>('memory-celebration')), findsOneWidget);
      expect(find.text('¡Lo lograste!'), findsOneWidget);
      expect(find.text('Busquemos las parejas iguales.'), findsOneWidget);
      for (var star = 0; star < 3; star++) {
        expect(find.byKey(ValueKey<String>('memory-star-$star-earned')), findsOneWidget);
      }
      verify(() => repository.saveMemoryProgress(any())).called(1);

      await tester.pump(MemoryLadderCubit.celebrationDuration);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const ValueKey<String>('memory-celebration')), findsNothing);
      expect(cardCount(), 6);
      expect(find.byKey(const ValueKey<String>('memory-time-bar')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('memory-level-dot-2-reached')), findsOneWidget);
    });

    testWidgets('a clumsy win still celebrates, showing the missing stars as outlines', (tester) async {
      await pumpScreen(tester);
      final pairs = pairsOf(tester);

      for (var miss = 0; miss < 4; miss++) {
        await tapCard(tester, pairs[0][0]);
        await tapCard(tester, pairs[1][0]);
        await tester.pump(MemoryLadderCubit.mismatchDelay);
        await tester.pump(const Duration(milliseconds: 450));
      }
      await winPerfectly(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey<String>('memory-celebration')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('memory-star-0-earned')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('memory-star-2-empty')), findsOneWidget);
    });

    testWidgets('beating the last level shows the golden badge celebration', (tester) async {
      await pumpScreen(tester, level: 5);

      await winPerfectly(tester);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byKey(const ValueKey<String>('memory-badge-celebration')), findsOneWidget);
      expect(find.text('¡Insignia dorada!'), findsOneWidget);

      await tester.pump(MemoryLadderCubit.celebrationDuration);
      await tester.pump(const Duration(milliseconds: 500));
      expect(cardCount(), 4);
    });

    testWidgets('time up shows a kind notice and deals an easier board', (tester) async {
      await pumpScreen(tester, level: 2);

      await tapCard(tester, 0);
      final fill = find.byKey(const ValueKey<String>('memory-time-bar-fill'));
      final double fullWidth = tester.getSize(fill).width;
      await tester.pump(const Duration(seconds: 45));
      expect(tester.getSize(fill).width, lessThan(fullWidth));

      await tester.pump(const Duration(seconds: 46));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey<String>('memory-time-up')), findsOneWidget);
      expect(find.text('¡Se acabó el tiempo! Probemos con menos cartas'), findsOneWidget);

      await tester.pump(MemoryLadderCubit.timeUpDuration);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const ValueKey<String>('memory-time-up')), findsNothing);
      expect(cardCount(), 4);
    });

    testWidgets('the timer pauses while the app is in the background', (tester) async {
      await pumpScreen(tester, level: 2);
      await tapCard(tester, 0);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 120));
      expect(find.byKey(const ValueKey<String>('memory-time-up')), findsNothing);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 91));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const ValueKey<String>('memory-time-up')), findsOneWidget);
    });

    testWidgets('the time bar empties towards the start of the reading direction (RTL)', (tester) async {
      await pumpScreen(tester, level: 2, locale: const Locale('ar'));
      await tapCard(tester, 0);
      await tester.pump(const Duration(seconds: 45));

      final Rect bar = tester.getRect(find.byKey(const ValueKey<String>('memory-time-bar')));
      final Rect fill = tester.getRect(find.byKey(const ValueKey<String>('memory-time-bar-fill')));
      expect(fill.width, lessThan(bar.width));
      expect(fill.right, moreOrLessEquals(bar.right));
    });

    testWidgets('a single back only shows a hint; a second one within the window exits', (tester) async {
      await pumpScreen(tester);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('exit-repeat-hint')), findsOneWidget);
      expect(find.text('Repite el gesto para salir'), findsOneWidget);
      final TextStyle hintStyle = tester.widget<RichText>(
        find.descendant(of: find.byKey(const ValueKey<String>('exit-repeat-hint')), matching: find.byType(RichText)),
      ).text.style!;
      expect(hintStyle.decoration, isNot(TextDecoration.underline), reason: 'hint must not use the fallback style');
      expect(find.byType(MemoryGameScreen), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const ValueKey<String>('exit-repeat-hint')), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(MemoryGameScreen), findsNothing);
      expect(find.text('launcher'), findsOneWidget);
    });
  });
}
