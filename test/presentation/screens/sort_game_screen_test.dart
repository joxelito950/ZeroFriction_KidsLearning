import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/sorting/sort_board.dart';
import 'package:toddler_logic/domain/sorting/sort_catalog.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/sort_game/sort_game_cubit.dart';
import 'package:toddler_logic/presentation/blocs/sort_game/sort_game_state.dart';
import 'package:toddler_logic/presentation/screens/sort_game_screen.dart';
import 'package:toddler_logic/presentation/widgets/gesture_hint.dart';
import 'package:toddler_logic/presentation/widgets/memory_time_bar.dart';
import 'package:toddler_logic/presentation/widgets/place_board_view.dart';
import 'package:toddler_logic/presentation/widgets/sort_board_view.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => SortGameScreen(random: Random(7))),
            ),
            child: const Text('launcher'),
          ),
        ),
      );
}

/// HU-027, entrega 2: la pantalla de «Clasificar» por color.
void main() {
  setUpAll(registerMemoryGameFallbacks);

  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  const Size portrait = Size(411, 914);
  const Size landscape = Size(914, 411);

  Future<void> pumpScreen(
    WidgetTester tester, {
    int level = 4,
    GameDifficulty round = GameDifficulty.bronze,
    Size size = portrait,
    Locale locale = testLocale,
  }) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    when(() => repository.readGameProgress(GameId.sorting)).thenAnswer((_) async => progressAt(level, round: round));
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

  void givenPremium() => when(() => repository.readUserProfile())
      .thenAnswer((_) async => const UserProfile(isPremium: true, isSoundEnabled: true));

  SortGameCubit cubitOf(WidgetTester tester) => tester.element(find.byType(SortBoardView)).read<SortGameCubit>();
  SortGameState stateOf(WidgetTester tester) => cubitOf(tester).state;
  Offset centerOf(WidgetTester tester, String key) => tester.getCenter(find.byKey(ValueKey<String>(key)));

  Future<void> dragTo(WidgetTester tester, SortPiece piece, SortColor basket) async {
    final Offset from = centerOf(tester, 'sort-tray-${piece.id}');
    await tester.dragFrom(from, centerOf(tester, 'sort-place-${basket.name}') - from);
    await tester.pump();
    await tester.pump(PlaceBoardView.flightDuration + const Duration(milliseconds: 50));
  }

  testWidgets('shows the title, the instructions, the baskets with their sample and the tray', (tester) async {
    await pumpScreen(tester);
    final AppLocalizations l10n = lookupAppLocalizations(testLocale);
    expect(find.text(l10n.sortingGameTitle), findsOneWidget);
    expect(find.text(l10n.sortingGameInstructions), findsOneWidget);
    final SortGameState state = stateOf(tester);
    for (final SortColor basket in state.board!.baskets) {
      final Finder card = find.byKey(ValueKey<String>('sort-place-${basket.name}'));
      expect(card, findsOneWidget);
      expect(find.descendant(of: card, matching: find.text(basket.sample.symbol)), findsOneWidget,
          reason: 'the sample tells what goes in');
    }
    for (final SortPiece piece in state.pieces) {
      expect(find.byKey(ValueKey<String>('sort-tray-${piece.id}')), findsOneWidget);
    }
    expect(find.byType(MemoryTimeBar), findsNothing, reason: 'bronze has no time');
  });

  testWidgets('an object dropped on its basket stays there; on another one it goes back and counts a mistake',
      (tester) async {
    await pumpScreen(tester);
    final SortGameState state = stateOf(tester);
    final SortPiece piece = state.pieces.first;
    final SortColor wrong = state.board!.baskets.firstWhere((basket) => basket != piece.color);

    await dragTo(tester, piece, wrong);
    expect(stateOf(tester).fails, 1);
    expect(stateOf(tester).moves, 1);
    expect(find.byKey(ValueKey<String>('sort-tray-${piece.id}')), findsOneWidget);

    await dragTo(tester, piece, piece.color);
    expect(stateOf(tester).placed, {piece.id});
    expect(stateOf(tester).moves, 2);
    expect(find.byKey(ValueKey<String>('sort-placed-${piece.id}')), findsOneWidget);
    expect(find.text('Movimientos: 2'), findsOneWidget);
  });

  testWidgets('tapping works too: the object, then its basket (HU-039)', (tester) async {
    await pumpScreen(tester);
    final SortPiece piece = stateOf(tester).pieces.first;
    await tester.tap(find.byKey(ValueKey<String>('sort-tray-${piece.id}')));
    await tester.pump();
    await tester.tap(find.byKey(ValueKey<String>('sort-place-${piece.color.name}')));
    await tester.pump(PlaceBoardView.flightDuration + const Duration(milliseconds: 50));
    expect(stateOf(tester).placed, {piece.id});
  });

  testWidgets('with the screen reader: choose an object, then its basket, which then says what it holds',
      (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpScreen(tester);
    final AppLocalizations l10n = lookupAppLocalizations(testLocale);
    final SortPiece piece = stateOf(tester).pieces.first;
    final String name = l10n.sortingObjectName(piece.object.name);
    final String basket = l10n.sortingBasketName(piece.color.name);

    tester.semantics.tap(find.semantics.byLabel(l10n.sortingObjectSemantics(name)).first);
    await tester.pump();
    tester.semantics.tap(find.semantics.byLabel(basket));
    await tester.pump();
    expect(stateOf(tester).placed, {piece.id});
    expect(find.bySemanticsLabel('$basket: $name'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('every object and basket has its own name in each language', (tester) async {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      final AppLocalizations l10n = lookupAppLocalizations(locale);
      final Set<String> objects = {
        for (final SortObject object in SortObject.values) l10n.sortingObjectName(object.name)
      };
      expect(objects, hasLength(SortObject.values.length), reason: locale.languageCode);
      expect(objects, isNot(contains(l10n.sortingObjectName('unknown'))), reason: locale.languageCode);
      final Set<String> baskets = {for (final SortColor color in SortColor.values) l10n.sortingBasketName(color.name)};
      expect(baskets, hasLength(SortColor.values.length), reason: locale.languageCode);
      expect(baskets, isNot(contains(l10n.sortingBasketName('unknown'))), reason: locale.languageCode);
    }
  });

  testWidgets('sorting every object celebrates, saves and moves to the next level', (tester) async {
    await pumpScreen(tester);
    final SortGameState state = stateOf(tester);
    for (final SortPiece piece in state.pieces) {
      await dragTo(tester, piece, piece.color);
    }
    expect(stateOf(tester).phase, SortPhase.celebrating);
    expect(stateOf(tester).stars, 3);
    await tester.pump(SortGameCubit.celebrationDuration);
    await tester.pump(const Duration(milliseconds: 500));
    expect(stateOf(tester).level, 5);
    final GameProgress saved =
        verify(() => repository.saveGameProgress(GameId.sorting, captureAny())).captured.last as GameProgress;
    expect(saved.position.level, 5);
  });

  testWidgets('the bronze tutorial shows the sample itself in the tray', (tester) async {
    await pumpScreen(tester, level: 1);
    final SortGameState state = stateOf(tester);
    expect(state.pieces, hasLength(2));
    for (final SortPiece piece in state.pieces) {
      expect(piece.object, piece.color.sample);
    }
  });

  testWidgets('from emerald: orange and purple can come, with a free basket', (tester) async {
    givenPremium();
    await pumpScreen(tester, level: 5, round: GameDifficulty.emerald);
    final SortGameState state = stateOf(tester);
    expect(state.board!.baskets, hasLength(5));
    expect(state.board!.freeBaskets, hasLength(1));
    expect(find.byType(MemoryTimeBar), findsOneWidget);
  });

  testWidgets('from gold the time bar shows and running out shows a helpful notice', (tester) async {
    givenPremium();
    await pumpScreen(tester, round: GameDifficulty.gold);
    expect(find.byType(MemoryTimeBar), findsOneWidget);
    cubitOf(tester).grab(stateOf(tester).pieces.first.id);
    await tester.pump(stateOf(tester).timeLimit! + const Duration(milliseconds: 200));
    expect(stateOf(tester).phase, SortPhase.timeUp);
    expect(find.text(lookupAppLocalizations(testLocale).sortingTimeUpFewerObjects), findsOneWidget);
    await tester.pump(SortGameCubit.timeUpDuration);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('in bronze the hand shows the drag', (tester) async {
    await pumpScreen(tester);
    await tester.pump(GestureHint.defaultFirstDelay);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey<String>('gesture-hint-hand')), findsOneWidget);
  });

  testWidgets('from silver on the hand never shows (Helps)', (tester) async {
    await pumpScreen(tester, round: GameDifficulty.silver);
    await tester.pump(GestureHint.defaultFirstDelay);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey<String>('gesture-hint-hand')), findsNothing);
  });

  testWidgets('a board only counts as in progress once touched (HU-009 R4)', (tester) async {
    await pumpScreen(tester);
    final SortGameState state = stateOf(tester);
    expect(SortGameScreen.boardInProgress(state), isFalse);
    expect(SortGameScreen.boardInProgress(state.copyWith(fails: 1)), isTrue);
    expect(SortGameScreen.boardInProgress(state.copyWith(phase: SortPhase.celebrating)), isTrue);
    expect(SortGameScreen.boardInProgress(const SortGameState()), isFalse);
  });

  // HU-027 criterio 4: el tablero más grande (8 objetos, 5 cestas) cabe en el
  // teléfono compacto, en vertical y en horizontal, en todos los idiomas.
  for (final Locale locale in AppLocalizations.supportedLocales) {
    for (final (String name, Size size) in [('portrait', portrait), ('landscape', landscape)]) {
      testWidgets('level 8 fits in compact $name (${locale.languageCode})', (tester) async {
        givenPremium();
        await pumpScreen(tester, level: 8, round: GameDifficulty.emerald, size: size, locale: locale);
        final Rect screen = Offset.zero & size;
        final SortGameState state = stateOf(tester);
        for (final SortColor basket in state.board!.baskets) {
          final Rect rect = tester.getRect(find.byKey(ValueKey<String>('sort-place-${basket.name}')));
          expect(screen.contains(rect.topLeft) && screen.contains(rect.bottomRight - const Offset(0.1, 0.1)), isTrue,
              reason: basket.name);
          expect(rect.width, greaterThan(48), reason: '${basket.name} is big enough to aim at');
        }
        for (final SortPiece piece in state.pieces) {
          final Rect rect = tester.getRect(find.byKey(ValueKey<String>('sort-tray-${piece.id}')));
          expect(screen.contains(rect.bottomRight - const Offset(0.1, 0.1)), isTrue, reason: piece.id);
          expect(rect.width, greaterThanOrEqualTo(44), reason: '${piece.id} is a touch target');
        }
      });
    }
  }

  for (final (String name, Size size) in [('portrait', portrait), ('landscape', landscape)]) {
    for (final Locale locale in const [Locale('de'), Locale('ar')]) {
      testWidgets('level 8 fits with the largest text in compact $name (${locale.languageCode})', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        givenPremium();
        await pumpScreen(tester, level: 8, round: GameDifficulty.emerald, size: size, locale: locale);
        expect(tester.takeException(), isNull);
        expect(find.byType(SortBoardView), findsOneWidget);
      });
    }
  }
}
