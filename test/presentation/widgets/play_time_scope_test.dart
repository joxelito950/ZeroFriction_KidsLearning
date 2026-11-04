import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/parental/daily_play_time.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_cubit.dart';
import 'package:toddler_logic/presentation/blocs/play_time/play_time_cubit.dart';
import 'package:toddler_logic/presentation/screens/main_menu_screen.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';
import 'package:toddler_logic/presentation/screens/parental_gate_screen.dart';
import 'package:toddler_logic/presentation/screens/rest_screen.dart';
import 'package:toddler_logic/presentation/widgets/memory_board.dart';
import 'package:toddler_logic/presentation/widgets/play_time_scope.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

void main() {
  setUpAll(registerMemoryGameFallbacks);

  final DateTime today = DateTime(2026, 11, 4, 17);
  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  void storePlayed(Duration played, {int limit = 15}) {
    when(() => repository.readParentalSettings()).thenAnswer(
      (_) async => ParentalSettings(dailyLimitMinutes: limit, playTime: DailyPlayTime(day: today, played: played)),
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale, now: () => today));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  PlayTimeCubit playTimeOf(WidgetTester tester) => tester.element(find.byType(PlayTimeScope)).read<PlayTimeCubit>();

  Finder menuGame() => find.text(l10n.menuMemoryTitle).hitTestable();

  testWidgets('with the limit already reached, the app opens on the rest screen without games (R5)', (tester) async {
    storePlayed(const Duration(minutes: 20));
    await pumpApp(tester);

    expect(find.byType(RestScreen), findsOneWidget);
    expect(find.text(l10n.restTitle), findsOneWidget);
    expect(find.text(l10n.restSubtitle), findsOneWidget);
    expect(menuGame(), findsNothing);
    // Nada en la pantalla abre un juego (criterio 4).
    await tester.tap(find.text(l10n.restTitle));
    await tester.pump();
    expect(find.byType(MemoryGameScreen), findsNothing);
  });

  testWidgets('without a limit, the rest screen never appears (criterion 8)', (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(minutes: 3));

    expect(find.byType(RestScreen), findsNothing);
    expect(menuGame(), findsOneWidget);
  });

  testWidgets('reaching the limit mid-board lets the board finish, then shows the rest screen (R4, criterion 3)',
      (tester) async {
    storePlayed(const Duration(minutes: 14, seconds: 55));
    await pumpApp(tester);
    await tester.tap(menuGame());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final MemoryLadderCubit game = tester.element(find.byType(MemoryBoard)).read<MemoryLadderCubit>();
    final cards = game.state.cards;
    final pairs = <String, List<int>>{};
    for (var i = 0; i < cards.length; i++) {
      pairs.putIfAbsent(cards[i].assetPath, () => []).add(i);
    }
    final List<List<int>> both = pairs.values.toList();

    await tester.tap(find.byKey(ValueKey<String>('memory-card-${both[0][0]}')));
    await tester.pump(const Duration(seconds: 8));
    expect(playTimeOf(tester).state.limitReached, isTrue);
    expect(find.byType(RestScreen), findsNothing);

    await tester.tap(find.byKey(ValueKey<String>('memory-card-${both[0][1]}')));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.tap(find.byKey(ValueKey<String>('memory-card-${both[1][0]}')));
    await tester.pump(const Duration(milliseconds: 450));
    await tester.tap(find.byKey(ValueKey<String>('memory-card-${both[1][1]}')));
    await tester.pump(const Duration(milliseconds: 300));
    // La celebración se ve entera.
    expect(find.byType(RestScreen), findsNothing);

    await tester.pump(MemoryLadderCubit.celebrationDuration);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(RestScreen), findsOneWidget);
    expect(find.byType(MemoryGameScreen), findsNothing);
  });

  testWidgets('15 more minutes close the rest screen and the menu is back (R6, criterion 5)', (tester) async {
    storePlayed(const Duration(minutes: 15));
    await pumpApp(tester);
    expect(find.byType(RestScreen), findsOneWidget);

    await playTimeOf(tester).grantExtra();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(RestScreen), findsNothing);
    expect(menuGame(), findsOneWidget);
  });

  testWidgets('the rest screen opens the parents zone with a double tap and comes back if the adult leaves',
      (tester) async {
    storePlayed(const Duration(minutes: 15));
    await pumpApp(tester);

    final Finder parents = find.byKey(const ValueKey<String>('rest-parents-zone'));
    await tester.tap(parents);
    await tester.pump();
    await tester.tap(parents);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(ParentalGateScreen), findsOneWidget);
    expect(playTimeOf(tester).state.inAdultArea, isTrue);

    // Al pasar a segundo plano, el desafío vuelve al menú (HU-004 R7) y el
    // descanso tiene que volver a aparecer.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(); // la pantalla de descanso se abre al terminar de cerrarse el desafío
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ParentalGateScreen), findsNothing);
    expect(find.byType(RestScreen), findsOneWidget);
    expect(menuGame(), findsNothing);
  });

  testWidgets('a lower limit set while playing in the menu shows the rest screen at once (R7)', (tester) async {
    storePlayed(const Duration(minutes: 20), limit: 60);
    await pumpApp(tester);
    expect(find.byType(MainMenuScreen), findsOneWidget);
    expect(find.byType(RestScreen), findsNothing);

    await playTimeOf(tester).setLimit(15);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(RestScreen), findsOneWidget);
  });

  testWidgets('time does not count with the app in the background (criterion 6)', (tester) async {
    storePlayed(Duration.zero);
    await pumpApp(tester);
    await tester.pump(const Duration(seconds: 5));
    final Duration before = playTimeOf(tester).state.today.played;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(minutes: 2));
    expect(playTimeOf(tester).state.today.played, before);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 3));
    expect(playTimeOf(tester).state.today.played, before + const Duration(seconds: 3));
  });
}
