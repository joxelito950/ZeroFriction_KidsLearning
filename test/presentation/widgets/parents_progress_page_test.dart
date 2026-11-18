import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/parental/play_history.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/game_settings/game_settings_cubit.dart';
import 'package:toddler_logic/presentation/blocs/parents_progress/parents_progress_cubit.dart';
import 'package:toddler_logic/presentation/widgets/medal_badge.dart';
import 'package:toddler_logic/presentation/widgets/parents_progress_page.dart';
import 'package:toddler_logic/presentation/widgets/play_week_chart.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

/// HU-034 entregas 3 y 4: la pantalla «Su progreso» y la sugerencia.
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  late MockPersistenceRepository repository;
  late Map<GameId, GameProgress> saved;
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    saved = {};
    when(() => repository.readGameProgress(any())).thenAnswer(
        (invocation) async => saved[invocation.positionalArguments.single as GameId] ?? GameProgress.initial());
    when(() => repository.saveGameProgress(any(), any())).thenAnswer((invocation) async {
      saved[invocation.positionalArguments[0] as GameId] = invocation.positionalArguments[1] as GameProgress;
    });
  });

  GameProgress stuckIn(GameDifficulty round, {int level = 4}) => GameProgress(
        position: RoundPosition(round: round, level: level),
        lastPlayedAt: today,
        stuckLevel: level,
        stuckFalls: GameProgress.stuckThreshold,
      );

  Future<void> pumpPage(WidgetTester tester, {Locale locale = testLocale}) async {
    await pumpSettingPage(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<ParentsProgressCubit>(create: (_) => ParentsProgressCubit(repository: repository)..load()),
          BlocProvider<GameSettingsCubit>(create: (_) => GameSettingsCubit(repository: repository)..load()),
        ],
        child: const ParentsProgressPage(),
      ),
      repository: repository,
      locale: locale,
    );
    // Los ajustes se leen al pedirlos por primera vez: un fotograma más.
    await tester.pump();
  }

  Finder key(String value) => find.byKey(ValueKey<String>(value));

  Future<void> tapKey(WidgetTester tester, String value) async {
    await tester.ensureVisible(key(value));
    await tester.pump();
    await tester.tap(key(value));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('a child who never played: games to discover, an empty week and no alarm (criterion 2)', (tester) async {
    await pumpPage(tester);
    expect(find.text(l10n.parentsProgressSentenceEmpty), findsOneWidget);
    for (final GameId game in GameId.values) {
      expect(key('progress-undiscovered-${game.name}'), findsOneWidget);
    }
    expect(find.byKey(const ValueKey<String>('week-bar-current')), findsWidgets);
    for (final Container bar in tester.widgetList<Container>(key('week-bar-current'))) {
      expect(bar.constraints?.maxHeight, 0);
    }
    expect(find.text(l10n.parentsProgressWeekTotal(l10n.parentsZonePlayTimeMinutes(0))), findsOneWidget);
    expect(find.textContaining('%'), findsNothing);
  });

  testWidgets('cards show only earned medals, what it explores and the star total (criterion 3)', (tester) async {
    saved[GameId.shadows] = GameProgress(
      position: const RoundPosition(round: GameDifficulty.silver, level: 3),
      medals: const {GameDifficulty.bronze, GameDifficulty.silver},
      records: {
        RoundLevel(GameDifficulty.bronze, 2): LevelRecord(bestStars: 3, achievedAt: today),
        RoundLevel(GameDifficulty.bronze, 3): LevelRecord(bestStars: 2, achievedAt: today),
      },
      lastPlayedAt: today,
    );
    await pumpPage(tester);
    expect(key('progress-medal-shadows-bronze'), findsOneWidget);
    expect(key('progress-medal-shadows-silver'), findsOneWidget);
    expect(key('progress-medal-shadows-gold'), findsNothing, reason: 'the missing ones do not appear');
    expect(find.text(l10n.parentsProgressExploring(l10n.roundSilver, 3)), findsOneWidget);
    expect(find.text(l10n.parentsProgressStars(5, ShadowLadder.rounds.maxStars)), findsOneWidget);
    expect(key('progress-undiscovered-shadows'), findsNothing);
    expect(key('progress-undiscovered-memory'), findsOneWidget);
  });

  testWidgets('the star total opens the per-level detail; it closes with Close (criterion 4)', (tester) async {
    saved[GameId.memory] = GameProgress(
      position: const RoundPosition(round: GameDifficulty.bronze, level: 3),
      records: {RoundLevel(GameDifficulty.bronze, 2): LevelRecord(bestStars: 2, achievedAt: today)},
      lastPlayedAt: today,
    );
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpPage(tester);
    await tapKey(tester, 'progress-stars-memory');

    expect(key('progress-stars-dialog'), findsOneWidget);
    expect(find.text(l10n.parentsProgressStarsTitle(l10n.menuMemoryTitle)), findsOneWidget);
    expect(find.bySemanticsLabel(l10n.parentsProgressLevelSemantics(2, 2)), findsOneWidget);
    final Finder level2 = key('progress-level-bronze-2');
    expect(find.descendant(of: level2, matching: find.byIcon(Icons.star_rounded)), findsNWidgets(2));
    expect(find.descendant(of: level2, matching: find.byIcon(Icons.star_outline_rounded)), findsOneWidget);
    expect(key('progress-level-bronze-3-new'), findsOneWidget, reason: 'not played: to discover');
    expect(key('progress-round-new-silver'), findsOneWidget);
    expect(find.descendant(of: key('progress-stars-dialog'), matching: find.byType(MedalBadge)),
        findsNWidgets(GameDifficulty.values.length));

    await tapKey(tester, 'progress-stars-close');
    expect(key('progress-stars-dialog'), findsNothing);
    semantics.dispose();
  });

  testWidgets('the sentence names the favourite game and its best medal; the week adds 6 days', (tester) async {
    when(() => repository.readPlayHistory(any())).thenAnswer((_) async => PlayHistory([
          PlayDay(day: today, byGame: {GameId.shadows: const Duration(minutes: 50)}),
          PlayDay(
              day: DateTime(today.year, today.month, today.day - 2),
              byGame: {GameId.memory: const Duration(minutes: 20)}),
        ]));
    saved[GameId.shadows] = GameProgress(
      position: const RoundPosition(round: GameDifficulty.silver, level: 2),
      medals: const {GameDifficulty.bronze},
      lastPlayedAt: today,
    );
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpPage(tester);

    expect(find.text(l10n.parentsProgressSentenceMedal(l10n.shadowsGameTitle, l10n.roundBronze)), findsOneWidget);
    expect(find.text(l10n.parentsProgressWeekTotal(l10n.parentsProgressHoursMinutes(1, 10))), findsOneWidget);
    expect(find.text('50'), findsOneWidget, reason: 'minutes above the bar');
    // R5: cada barra se lee como una frase, el hueco no.
    expect(find.bySemanticsLabel(RegExp(', ${RegExp.escape(l10n.parentsZonePlayTimeMinutes(50))}\$')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
      'in gold, a stuck game suggests silver; confirming switches the round and keeps achievements (criterion 6)',
      (tester) async {
    saved[GameId.shadows] = stuckIn(GameDifficulty.gold);
    await pumpPage(tester);
    expect(find.text(l10n.parentsProgressStuckTitle(l10n.shadowsGameTitle)), findsOneWidget);
    expect(find.text(l10n.parentsProgressStuckLower(l10n.roundSilver)), findsOneWidget);

    // Cancelar no cambia nada.
    await tapKey(tester, 'progress-suggestion-act-shadows');
    await tapKey(tester, 'progress-lower-cancel');
    expect(saved[GameId.shadows]!.position.round, GameDifficulty.gold);

    await tapKey(tester, 'progress-suggestion-act-shadows');
    expect(find.text(l10n.parentsProgressLowerConfirm(l10n.shadowsGameTitle, l10n.roundSilver)), findsOneWidget);
    await tapKey(tester, 'progress-lower-confirm');
    expect(saved[GameId.shadows]!.position, const RoundPosition(round: GameDifficulty.silver, level: 2));
    expect(saved[GameId.shadows]!.isStuck, isFalse);
    expect(key('progress-suggestion-shadows'), findsNothing);
  });

  testWidgets('«Not now» hides the suggestion and clears the count', (tester) async {
    saved[GameId.memory] = stuckIn(GameDifficulty.silver);
    await pumpPage(tester);
    await tapKey(tester, 'progress-suggestion-dismiss-memory');
    expect(key('progress-suggestion-memory'), findsNothing);
    expect(saved[GameId.memory]!.stuckFalls, 0);
    expect(saved[GameId.memory]!.position.round, GameDifficulty.silver);
  });

  testWidgets('in bronze it suggests playing without time, when available (criterion 7)', (tester) async {
    // «Jugar sin tiempo» es Premium (HU-030); con D-040, abierto para todos.
    when(() => repository.readUserProfile())
        .thenAnswer((_) async => const UserProfile(isPremium: true, isSoundEnabled: true));
    saved[GameId.oddOneOut] = stuckIn(GameDifficulty.bronze, level: 3);
    await pumpPage(tester);
    expect(find.text(l10n.parentsProgressStuckNoTime), findsOneWidget);
    await tapKey(tester, 'progress-suggestion-act-oddOneOut');
    final ParentalSettings settings =
        verify(() => repository.saveParentalSettings(captureAny())).captured.last as ParentalSettings;
    expect(settings.timerDisabled, isTrue);
    expect(key('progress-suggestion-oddOneOut'), findsNothing);
  });

  testWidgets('in bronze without Premium there is nothing to suggest', (tester) async {
    // Los tests parten de las reglas de pago (memory_game_test_support), sin D-040.
    saved[GameId.oddOneOut] = stuckIn(GameDifficulty.bronze, level: 3);
    await pumpPage(tester);
    expect(key('progress-suggestion-oddOneOut'), findsNothing);
  });

  testWidgets('fits in Arabic, with the week mirrored (R6)', (tester) async {
    saved[GameId.shadows] = stuckIn(GameDifficulty.diamond);
    await pumpPage(tester, locale: const Locale('ar'));
    expect(tester.takeException(), isNull);
    final double first = tester.getCenter(key('week-slot-0')).dx;
    final double last = tester.getCenter(key('week-slot-6')).dx;
    expect(first, greaterThan(last), reason: 'the first day is on the right');
  });

  test('durations read as minutes or hours and minutes', () {
    expect(PlayWeekChart.duration(l10n, const Duration(minutes: 59, seconds: 50)), l10n.parentsZonePlayTimeMinutes(59));
    expect(PlayWeekChart.duration(l10n, const Duration(minutes: 125)), l10n.parentsProgressHoursMinutes(2, 5));
  });

  test('no text of «Their progress» shows percentages, in the 9 languages (criterion 8)', () {
    for (final File file in Directory('lib/l10n').listSync().whereType<File>().where((f) => f.path.endsWith('.arb'))) {
      final Map<String, dynamic> arb = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> entry in arb.entries) {
        if (!entry.key.startsWith('parentsProgress')) continue;
        expect(entry.value as String, isNot(contains('%')), reason: '${file.path} ${entry.key}');
      }
    }
  });

  group('ParentsProgressCubit', () {
    test('a failed read reports the error and still ends loaded', () async {
      when(() => repository.readGameProgress(any())).thenThrow(StateError('disk'));
      final ParentsProgressCubit cubit = ParentsProgressCubit(repository: repository);
      await cubit.load();
      await cubit.dismiss(GameId.memory);
      expect(cubit.state.loaded, isTrue);
      await cubit.close();
      // Cerrado, ni lee ni avisa.
      await cubit.load();
      await cubit.dismiss(GameId.memory);
    });

    test('states compare by value and tell when there is a suggestion', () {
      final ParentsProgressState a =
          ParentsProgressState(loaded: true, progress: {GameId.memory: stuckIn(GameDifficulty.gold)});
      final ParentsProgressState b =
          ParentsProgressState(loaded: true, progress: {GameId.memory: stuckIn(GameDifficulty.gold)});
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a.hasSuggestion, isTrue);
      expect(ParentsProgressState().hasSuggestion, isFalse);
    });
  });
}
