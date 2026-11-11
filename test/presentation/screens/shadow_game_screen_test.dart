import 'dart:math';
import 'package:flutter/semantics.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';
import 'package:toddler_logic/presentation/blocs/shadow_game/shadow_game_cubit.dart';
import 'package:toddler_logic/presentation/blocs/shadow_game/shadow_game_state.dart';
import 'package:toddler_logic/presentation/screens/shadow_game_screen.dart';
import 'package:toddler_logic/presentation/widgets/gesture_hint.dart';
import 'package:toddler_logic/presentation/widgets/memory_level_indicator.dart';
import 'package:toddler_logic/presentation/widgets/shadow_board.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';

/// Abre el juego desde una pantalla previa, para poder comprobar la salida.
class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => ShadowGameScreen(random: Random(7))),
          ),
          child: const Text('launcher'),
        ),
      ),
    );
  }
}

/// HU-007, entrega 3: la pantalla de Sombras.
void main() {
  setUpAll(registerMemoryGameFallbacks);

  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  /// La animación arranca en el fotograma siguiente; después dura lo suyo.
  Future<void> finishIntro(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(ShadowBoard.introDuration + const Duration(milliseconds: 50));
    await tester.pump();
  }

  /// Teléfono compacto de los tests de diseño (D-011).
  const Size portrait = Size(411, 914);
  const Size landscape = Size(914, 411);

  Future<void> pumpScreen(
    WidgetTester tester, {
    int level = 1,
    GameDifficulty round = GameDifficulty.normal,
    bool premium = false,
    ParentalSettings? settings,
    Size size = portrait,
    Locale locale = testLocale,
    bool waitIntro = true,
  }) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    when(() => repository.readGameProgress(GameId.shadows)).thenAnswer((_) async => progressAt(level, round: round));
    when(() => repository.readUserProfile())
        .thenAnswer((_) async => UserProfile(isPremium: premium, isSoundEnabled: true));
    if (settings != null) when(() => repository.readParentalSettings()).thenAnswer((_) async => settings);
    await tester.pumpWidget(
      RepositoryProvider<IPersistenceRepository>.value(
        value: repository,
        child: localizedApp(locale: locale, home: const _Launcher()),
      ),
    );
    await tester.tap(find.text('launcher'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    if (waitIntro) await finishIntro(tester);
  }

  ShadowGameCubit cubitOf(WidgetTester tester) => tester.element(find.byType(ShadowBoard)).read<ShadowGameCubit>();
  ShadowGameState stateOf(WidgetTester tester) => cubitOf(tester).state;

  Offset centerOf(WidgetTester tester, String key) => tester.getCenter(find.byKey(ValueKey<String>(key)));

  /// Arrastra [object] hasta el centro de la sombra [shadow] y espera el vuelo.
  Future<void> dragTo(WidgetTester tester, String object, String shadow) async {
    final Offset from = centerOf(tester, 'shadow-object-$object');
    await tester.dragFrom(from, centerOf(tester, 'shadow-target-$shadow') - from);
    await tester.pump();
    await tester.pump(ShadowBoard.flightDuration + const Duration(milliseconds: 50));
  }

  String otherShadow(ShadowGameState state, String object) =>
      state.shadows.firstWhere((shadow) => shadow != object && !state.placed.contains(shadow));

  group('start (4.1, R19)', () {
    testWidgets('shows the title and icon, the 7 free levels, and the start animation before playing',
        (tester) async {
      await pumpScreen(tester, waitIntro: false);

      expect(find.text('Sombras'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('shadows-game-icon')), findsOneWidget);
      // Versión sin pago: 7 puntos y ningún candado hasta HU-006.
      expect(find.byKey(const ValueKey<String>('memory-level-dot-7-pending')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('memory-level-dot-8-pending')), findsNothing);
      expect(find.byKey(const ValueKey<String>('memory-level-dot-8-locked')), findsNothing);
      expect(stateOf(tester).phase, ShadowRoundPhase.introducing);
      final String first = stateOf(tester).objects.first;
      expect(find.byKey(ValueKey<String>('shadow-intro-$first')), findsOneWidget);
      expect(find.byKey(ValueKey<String>('shadow-object-$first')), findsNothing,
          reason: 'nothing can be dragged during the animation');

      await finishIntro(tester);
      expect(stateOf(tester).phase, ShadowRoundPhase.playing);
      expect(find.byKey(ValueKey<String>('shadow-object-$first')), findsOneWidget);
      expect(find.byKey(ValueKey<String>('shadow-silhouette-$first')), findsOneWidget);
    });

    testWidgets('with reduced motion the objects are already in the tray (R19)', (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue = FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
      await pumpScreen(tester, waitIntro: false);
      await tester.pump();

      expect(stateOf(tester).phase, ShadowRoundPhase.playing);
      final String object = stateOf(tester).objects.first;
      final Offset from = centerOf(tester, 'shadow-object-$object');
      await tester.dragFrom(from, centerOf(tester, 'shadow-target-$object') - from);
      await tester.pump();
      expect(find.byKey(ValueKey<String>('shadow-placed-$object')), findsOneWidget, reason: 'no flight');
    });

    testWidgets('Impossible starts without the animation', (tester) async {
      await pumpScreen(tester, round: GameDifficulty.impossible, waitIntro: false);
      expect(stateOf(tester).phase, ShadowRoundPhase.playing);
    });
  });

  group('dragging (R3, R4, R5, R17)', () {
    testWidgets('an object dropped on its shadow snaps and stays in colour', (tester) async {
      await pumpScreen(tester);
      final String object = stateOf(tester).objects.first;

      final TestGesture gesture = await tester.startGesture(centerOf(tester, 'shadow-object-$object'));
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('shadow-dragged')), findsOneWidget);
      await gesture.moveTo(centerOf(tester, 'shadow-target-$object'));
      await gesture.up();
      await tester.pump();
      expect(find.byKey(const ValueKey<String>('shadow-flying')), findsOneWidget);
      await tester.pump(ShadowBoard.flightDuration + const Duration(milliseconds: 50));

      expect(find.byKey(ValueKey<String>('shadow-placed-$object')), findsOneWidget);
      expect(find.byKey(ValueKey<String>('shadow-object-$object')), findsNothing);
    });

    testWidgets('an object dropped on another shadow goes back to the tray and counts a mistake', (tester) async {
      await pumpScreen(tester);
      final String object = stateOf(tester).objects.first;
      await dragTo(tester, object, otherShadow(stateOf(tester), object));

      expect(stateOf(tester).fails, 1);
      expect(find.byKey(ValueKey<String>('shadow-object-$object')), findsOneWidget);
      expect(stateOf(tester).placed, isEmpty);
    });

    testWidgets('a second finger cannot drag another object at the same time', (tester) async {
      await pumpScreen(tester);
      final [String first, String second] = stateOf(tester).objects;
      final TestGesture one = await tester.startGesture(centerOf(tester, 'shadow-object-$first'));
      await one.moveBy(const Offset(0, -40));
      await tester.pump();
      final TestGesture two = await tester.startGesture(centerOf(tester, 'shadow-object-$second'), pointer: 2);
      await two.moveBy(const Offset(0, -40));
      await tester.pump();
      expect(find.byKey(ValueKey<String>('shadow-object-$second')), findsOneWidget, reason: 'still in the tray');
      await two.up();
      await one.up();
      await tester.pump(ShadowBoard.flightDuration);
    });

    testWidgets('completing the tutorial invites to play, without stars (HU-037 R9)', (tester) async {
      await pumpScreen(tester);
      for (final object in List.of(stateOf(tester).objects)) {
        await dragTo(tester, object, object);
      }
      expect(find.byKey(const ValueKey<String>('play-invitation')), findsOneWidget);

      await tester.pump(ShadowGameCubit.invitationDuration);
      await tester.pump(const Duration(milliseconds: 500));
      expect(stateOf(tester).level, 2);
    });

    testWidgets('placing every object celebrates and moves to the next level (R8)', (tester) async {
      await pumpScreen(tester, level: 2);
      for (final object in List.of(stateOf(tester).objects)) {
        await dragTo(tester, object, object);
      }
      expect(find.byKey(const ValueKey<String>('memory-celebration')), findsOneWidget);

      await tester.pump(ShadowGameCubit.celebrationDuration);
      await tester.pump(const Duration(milliseconds: 500));
      expect(stateOf(tester).level, 3);
    });
  });

  group('screen reader (R16)', () {
    testWidgets('choosing an object and then its shadow places it', (tester) async {
      await pumpScreen(tester);
      final String object = stateOf(tester).objects.first;
      SemanticsProperties semanticsOf(String key) => tester
          .widget<Semantics>(find
              .descendant(of: find.byKey(ValueKey<String>(key)), matching: find.byType(Semantics), matchRoot: true)
              .first)
          .properties;

      expect(semanticsOf('shadow-object-$object').label, '$object para colocar');
      expect(semanticsOf('shadow-target-$object').onTap, isNull, reason: 'nothing chosen yet');
      semanticsOf('shadow-object-$object').onTap!();
      await tester.pump();
      expect(semanticsOf('shadow-object-$object').selected, isTrue);
      semanticsOf('shadow-target-$object').onTap!();
      await tester.pump();

      expect(stateOf(tester).placed, {object});
      expect(semanticsOf('shadow-target-$object').label, '$object en su sombra');
    });
  });

  group('time and tutorial (R7, R15)', () {
    testWidgets('with Premium, the time bar shows and running out shows a helpful notice', (tester) async {
      await pumpScreen(tester, level: 3, premium: true);
      expect(find.byKey(const ValueKey<String>('memory-time-bar')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('memory-level-dot-8-pending')), findsOneWidget);

      cubitOf(tester).grab(stateOf(tester).objects.first);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 5));
      expect(stateOf(tester).elapsed, Duration.zero, reason: 'paused in the background');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump(const Duration(seconds: 51));

      expect(find.text('¡Se acabó el tiempo! Probemos con menos dibujos.'), findsOneWidget);
      await tester.pump(ShadowGameCubit.timeUpDuration);
      await tester.pump(const Duration(milliseconds: 500));
      expect(stateOf(tester).level, 2);
    });

    testWidgets('losing the first timed level goes back to the tutorial calmly (HU-037)', (tester) async {
      await pumpScreen(tester, level: 2);
      cubitOf(tester).grab(stateOf(tester).objects.first);
      await tester.pump(const Duration(seconds: 61));
      expect(find.text('¡Se acabó el tiempo! Empecemos de nuevo, sin prisa.'), findsOneWidget);
      await tester.pump(ShadowGameCubit.timeUpDuration);
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('the hand shows the drag after a few seconds without touching', (tester) async {
      await pumpScreen(tester);
      await tester.pump(GestureHint.defaultFirstDelay);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const ValueKey<String>('gesture-hint-hand')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('gesture-hint-ghost')), findsOneWidget);
    });
  });

  group('layout (4.1, P13, R13, criterion 12)', () {
    for (final (String name, Size size) in [('portrait', portrait), ('landscape', landscape)]) {
      for (final locale in const [Locale('es'), Locale('ar')]) {
        testWidgets('level 8 fits in compact $name (${locale.languageCode}) with the shadows first',
            (tester) async {
          await pumpScreen(tester, level: 8, premium: true, size: size, locale: locale);
          expect(tester.takeException(), isNull);

          final Rect shadows = tester.getRect(find.byKey(const ValueKey<String>('shadow-zone-shadows')));
          final Rect tray = tester.getRect(find.byKey(const ValueKey<String>('shadow-zone-tray')));
          if (size.width > size.height) {
            expect(shadows.center.dx, lessThan(tray.center.dx), reason: 'shadows on the physical left');
          } else {
            expect(shadows.center.dy, lessThan(tray.center.dy), reason: 'shadows on top');
          }
          expect(stateOf(tester).shadows, hasLength(8));
          final Size screen = tester.view.physicalSize / tester.view.devicePixelRatio;
          for (final shadow in stateOf(tester).shadows) {
            final Rect rect = tester.getRect(find.byKey(ValueKey<String>('shadow-target-$shadow')));
            expect(Offset.zero & screen, predicate<Rect>((bounds) => bounds.intersect(rect) == rect), reason: shadow);
          }
        });
      }
    }

    test('the emoji never goes over 220 physical pixels, and both zones share the cell size', () {
      final geometry = ShadowBoardGeometry.compute(
        size: const Size(900, 900),
        layout: ShadowLayout.shadowsLast,
        shadows: const ['a', 'b'],
        objects: const ['a', 'b'],
        devicePixelRatio: 3,
      );
      expect(geometry.emojiSize, lessThanOrEqualTo(220 / 3));
      expect(geometry.shadowZone.top, greaterThan(geometry.trayZone.top), reason: 'shadows last: below');
      expect(geometry.shadowRects['a']!.size, geometry.trayRects['a']!.size);
    });
  });

  testWidgets('a board only counts as in progress once touched (HU-009 R4)', (tester) async {
    expect(ShadowGameScreen.boardInProgress(const ShadowGameState(phase: ShadowRoundPhase.playing)), isFalse);
    expect(ShadowGameScreen.boardInProgress(const ShadowGameState(phase: ShadowRoundPhase.playing, fails: 1)), isTrue);
    expect(ShadowGameScreen.boardInProgress(const ShadowGameState(phase: ShadowRoundPhase.celebrating)), isTrue);
    expect(ShadowGameScreen.boardInProgress(const ShadowGameState(phase: ShadowRoundPhase.introducing)), isFalse);
  });

  testWidgets('two «back» presses leave the game (D-025)', (tester) async {
    await pumpScreen(tester);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(ShadowGameScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ShadowGameScreen), findsNothing);
  });

  testWidgets('the level indicator can show a locked level for when Premium exists (R11, HU-006)', (tester) async {
    await tester.pumpWidget(localizedApp(
      home: const Scaffold(body: MemoryLevelIndicator(level: 2, total: 8, lockedLevel: 8)),
    ));
    expect(find.byKey(const ValueKey<String>('memory-level-dot-8-locked')), findsOneWidget);
    expect(find.bySemanticsLabel('Nivel 2 de 8. Nivel 8 bloqueado'), findsOneWidget);
  });
}
