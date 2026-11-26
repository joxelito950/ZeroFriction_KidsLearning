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
import 'package:toddler_logic/domain/sorting/sort_ladder.dart';
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

  SortBasket targetOf(WidgetTester tester, SortPiece piece) => stateOf(tester).board!.targetOf(piece);

  Future<void> dragTo(WidgetTester tester, SortPiece piece, SortBasket basket) async {
    final Offset from = centerOf(tester, 'sort-tray-${piece.id}');
    await tester.dragFrom(from, centerOf(tester, 'sort-place-${basket.id}') - from);
    await tester.pump();
    await tester.pump(PlaceBoardView.flightDuration + const Duration(milliseconds: 50));
  }

  testWidgets('shows the title, the instructions, the baskets with their sample and the tray', (tester) async {
    await pumpScreen(tester);
    final AppLocalizations l10n = lookupAppLocalizations(testLocale);
    expect(find.text(l10n.sortingGameTitle), findsOneWidget);
    expect(find.text(l10n.sortingGameInstructions), findsOneWidget);
    final SortGameState state = stateOf(tester);
    for (final SortBasket basket in state.board!.baskets) {
      final Finder card = find.byKey(ValueKey<String>('sort-place-${basket.id}'));
      expect(card, findsOneWidget);
      final Finder sample = find.byKey(ValueKey<String>('sort-sample-${basket.id}'));
      expect(find.descendant(of: sample, matching: find.text(basket.sample.symbol)), findsOneWidget,
          reason: 'the sample tells what goes in');
      expect(tester.getRect(card).contains(tester.getCenter(sample)), isTrue,
          reason: 'the sample is a tag on its basket');
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
    final SortBasket wrong = state.board!.baskets.firstWhere((basket) => !basket.accepts(piece));

    await dragTo(tester, piece, wrong);
    expect(stateOf(tester).fails, 1);
    expect(stateOf(tester).moves, 1);
    expect(find.byKey(ValueKey<String>('sort-tray-${piece.id}')), findsOneWidget);

    await dragTo(tester, piece, targetOf(tester, piece));
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
    await tester.tap(find.byKey(ValueKey<String>('sort-place-${targetOf(tester, piece).id}')));
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
    final String basket = l10n.sortingBasketName(piece.color!.name);

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
      await dragTo(tester, piece, targetOf(tester, piece));
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
      expect(piece.object, piece.color!.sample);
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

  testWidgets('gold sorts by size: the bears in big and small cards, one object in both sizes (3.4, P6)',
      (tester) async {
    givenPremium();
    await pumpScreen(tester, level: 5, round: GameDifficulty.gold);
    final SortGameState state = stateOf(tester);
    expect(state.board!.criterion, SortCriterion.size);
    final Rect big = tester.getRect(find.byKey(const ValueKey<String>('sort-place-big')));
    final Rect small = tester.getRect(find.byKey(const ValueKey<String>('sort-place-small')));
    expect(small.width, lessThan(big.width), reason: 'the basket itself is small');
    double fontOf(SortPiece piece) => tester
        .widget<Text>(
            find.descendant(of: find.byKey(ValueKey<String>('sort-tray-${piece.id}')), matching: find.byType(Text)))
        .style!
        .fontSize!;
    final SortPiece bigPiece = state.pieces.firstWhere((piece) => piece.size == SortSize.big);
    final SortPiece smallPiece = state.pieces.firstWhere((piece) => piece.size == SortSize.small);
    expect(fontOf(smallPiece), closeTo(fontOf(bigPiece) * 0.45, 0.01));

    await dragTo(tester, smallPiece, targetOf(tester, smallPiece));
    expect(stateOf(tester).placed, {smallPiece.id});
    await dragTo(tester, bigPiece, targetOf(tester, smallPiece));
    expect(stateOf(tester).fails, 1, reason: 'a big one in the small basket is a mistake');
  });

  testWidgets('the screen reader says the size of the object and of its basket', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    givenPremium();
    await pumpScreen(tester, level: 5, round: GameDifficulty.ruby);
    final AppLocalizations l10n = lookupAppLocalizations(testLocale);
    final SortPiece piece = stateOf(tester).pieces.first;
    final String size = l10n.sortingSizeName(piece.size.name);
    final String name = l10n.sortingWithSize(l10n.sortingObjectName(piece.object.name), size);
    tester.semantics.tap(find.semantics.byLabel(l10n.sortingObjectSemantics(name)).first);
    await tester.pump();
    tester.semantics.tap(find.semantics.byLabel(l10n.sortingSizeBasket(size)));
    await tester.pump();
    expect(stateOf(tester).placed, {piece.id});
    expect(find.bySemanticsLabel('${l10n.sortingSizeBasket(size)}: $name'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('obsidian sorts by colour and size: four baskets, each with its sample', (tester) async {
    givenPremium();
    await pumpScreen(tester, level: 5, round: GameDifficulty.obsidian);
    final SortGameState state = stateOf(tester);
    expect(state.board!.criterion, SortCriterion.colorAndSize);
    expect(state.board!.baskets, hasLength(4));
    for (final SortPiece piece in List.of(state.pieces)) {
      await dragTo(tester, piece, targetOf(tester, piece));
    }
    expect(stateOf(tester).phase, SortPhase.celebrating);
    await tester.pump(SortGameCubit.celebrationDuration);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('diamond level 8: six baskets and a tray of 4 that refills until 12 are sorted (4.3)', (tester) async {
    givenPremium();
    await pumpScreen(tester, level: 8, round: GameDifficulty.diamond);
    SortGameState state = stateOf(tester);
    expect(state.board!.baskets, hasLength(6));
    expect(state.pieces, hasLength(12));
    expect(state.trayPieces, hasLength(4));
    final SortPiece waiting =
        state.pieces.firstWhere((piece) => !state.trayPieces.any((shown) => shown.id == piece.id));
    expect(find.byKey(ValueKey<String>('sort-tray-${waiting.id}')), findsNothing,
        reason: 'the rest wait outside the tray');
    // El tiempo, por objeto: 20 s del nivel 8 de diamante × 12 / 8.
    expect(state.timeLimit, const Duration(seconds: 30));

    final SortPiece first = state.trayPieces.first;
    final Rect slot = tester.getRect(find.byKey(ValueKey<String>('sort-tray-${first.id}')));
    await dragTo(tester, first, targetOf(tester, first));
    state = stateOf(tester);
    expect(state.trayPieces, hasLength(4), reason: 'a new object comes in');
    final SortPiece newcomer = state.trayPieces.first;
    expect(newcomer.id, isNot(first.id));
    expect(tester.getRect(find.byKey(ValueKey<String>('sort-tray-${newcomer.id}'))), slot,
        reason: 'it takes the free place; the others do not move');

    for (var i = 0; i < 11; i++) {
      final SortPiece piece = stateOf(tester).trayPieces.first;
      await dragTo(tester, piece, targetOf(tester, piece));
    }
    expect(stateOf(tester).phase, SortPhase.celebrating);
    expect(stateOf(tester).stars, 3);
    await tester.pump(SortGameCubit.celebrationDuration);
    await tester.pump(const Duration(milliseconds: 500));
  });

  // HU-027 criterios 4 y 9: los tableros más grandes de cada forma de jugar
  // caben en el teléfono compacto, en vertical y en horizontal, en todos los
  // idiomas, y el objeto pequeño no baja de 28 dp.
  const List<(String, GameDifficulty, int)> biggest = [
    ('colour', GameDifficulty.emerald, 8),
    ('size', GameDifficulty.sapphire, 8),
    ('colour and size', GameDifficulty.obsidian, 8),
    ('refill', GameDifficulty.diamond, 8),
  ];
  for (final Locale locale in AppLocalizations.supportedLocales) {
    for (final (String name, Size size) in [('portrait', portrait), ('landscape', landscape)]) {
      for (final (String kind, GameDifficulty round, int level) in biggest) {
        testWidgets('$kind level $level fits in compact $name (${locale.languageCode})', (tester) async {
          givenPremium();
          await pumpScreen(tester, level: level, round: round, size: size, locale: locale);
          final Rect screen = Offset.zero & size;
          final SortGameState state = stateOf(tester);
          for (final SortBasket basket in state.board!.baskets) {
            final Rect rect = tester.getRect(find.byKey(ValueKey<String>('sort-place-${basket.id}')));
            expect(screen.contains(rect.topLeft) && screen.contains(rect.bottomRight - const Offset(0.1, 0.1)), isTrue,
                reason: basket.id);
            expect(rect.width, greaterThan(48), reason: '${basket.id} is big enough to aim at');
          }
          for (final SortPiece piece in state.trayPieces) {
            final Finder card = find.byKey(ValueKey<String>('sort-tray-${piece.id}'));
            final Rect rect = tester.getRect(card);
            expect(screen.contains(rect.bottomRight - const Offset(0.1, 0.1)), isTrue, reason: piece.id);
            expect(rect.width, greaterThanOrEqualTo(44), reason: '${piece.id} is a touch target');
            final double emoji =
                tester.widget<Text>(find.descendant(of: card, matching: find.byType(Text))).style!.fontSize!;
            expect(emoji, greaterThanOrEqualTo(28), reason: '${piece.id} is at least 28 dp (3.4)');
          }
        });
      }
    }
  }

  for (final (String name, Size size) in [('portrait', portrait), ('landscape', landscape)]) {
    for (final Locale locale in const [Locale('de'), Locale('ar')]) {
      for (final (String kind, GameDifficulty round, int level) in biggest) {
        testWidgets('$kind level $level fits with the largest text in compact $name (${locale.languageCode})',
            (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = 2.0;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          givenPremium();
          await pumpScreen(tester, level: level, round: round, size: size, locale: locale);
          expect(tester.takeException(), isNull);
          expect(find.byType(SortBoardView), findsOneWidget);
        });
      }
    }
  }
}
