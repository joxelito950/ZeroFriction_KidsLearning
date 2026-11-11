import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/game_settings/game_settings_cubit.dart';
import 'package:toddler_logic/presentation/widgets/parents_games_section.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

/// Sección «Juegos» de la Zona de Padres (HU-030, HU-016 y la ronda de cada juego de HU-037).
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  late MockPersistenceRepository repository;
  late ParentalSettings stored;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    stored = ParentalSettings.initial;
    when(() => repository.readParentalSettings()).thenAnswer((_) async => stored);
    when(() => repository.saveParentalSettings(any())).thenAnswer((invocation) async {
      stored = invocation.positionalArguments.single as ParentalSettings;
    });
  });

  void premium(bool value) {
    when(() => repository.readUserProfile())
        .thenAnswer((_) async => UserProfile(isPremium: value, isSoundEnabled: true));
  }

  Future<void> pumpSection(WidgetTester tester) async {
    await tester.pumpWidget(localizedApp(
      repository: repository,
      home: const Scaffold(body: SingleChildScrollView(child: ParentsGamesSection())),
    ));
    await tester.pump();
  }

  ChoiceChip chip(WidgetTester tester, GameId game, GameDifficulty round) =>
      tester.widget<ChoiceChip>(find.byKey(ValueKey<String>('round-${game.name}-${round.name}')));

  SwitchListTile noTime(WidgetTester tester) =>
      tester.widget<SwitchListTile>(find.byKey(const ValueKey<String>('games-no-time')));

  testWidgets('shows the round of each game, Easy for a new player (HU-037 P1, R1)', (tester) async {
    when(() => repository.readGameProgress(GameId.shadows))
        .thenAnswer((_) async => progressAt(3, round: GameDifficulty.impossible));
    await pumpSection(tester);

    expect(find.text(l10n.parentsZoneGamesTitle), findsOneWidget);
    expect(find.text(l10n.parentsZoneRoundsHint), findsOneWidget);
    expect(chip(tester, GameId.memory, GameDifficulty.easy).selected, isTrue);
    expect(chip(tester, GameId.shadows, GameDifficulty.impossible).selected, isTrue);
    // Sin Premium, «Jugar sin tiempo» no se muestra (R4, 2026-11-09).
    expect(find.byKey(const ValueKey<String>('games-no-time')), findsNothing);
  });

  testWidgets('choosing a round saves it in that game only, from its tutorial, keeping its medals (R5)', (tester) async {
    when(() => repository.readGameProgress(GameId.memory))
        .thenAnswer((_) async => progressAt(4, medals: const {GameDifficulty.easy}));
    await pumpSection(tester);

    await tester.tap(find.byKey(const ValueKey<String>('round-memory-easy')));
    await tester.pump();

    expect(chip(tester, GameId.memory, GameDifficulty.easy).selected, isTrue);
    final GameProgress saved =
        verify(() => repository.saveGameProgress(GameId.memory, captureAny())).captured.single as GameProgress;
    expect(saved.position.round, GameDifficulty.easy);
    expect(saved.position.level, 1);
    expect(saved.medals, {GameDifficulty.easy});
    verifyNever(() => repository.saveGameProgress(GameId.shadows, any()));
  });

  testWidgets('without Premium the switch is not shown until it can be bought (R4, 2026-11-09)', (tester) async {
    await pumpSection(tester);

    expect(find.byKey(const ValueKey<String>('games-no-time')), findsNothing);
    expect(find.textContaining(l10n.parentsZonePremiumOnly), findsNothing);
  });

  testWidgets('with Premium the switch turns the time off and saves it', (tester) async {
    premium(true);
    await pumpSection(tester);

    expect(find.textContaining(l10n.parentsZonePremiumOnly), findsNothing);
    await tester.tap(find.byKey(const ValueKey<String>('games-no-time')));
    await tester.pump();

    expect(noTime(tester).value, isTrue);
    expect(stored.timerDisabled, isTrue);
  });

  testWidgets('a setting saved with Premium is reset when Premium is gone (R11, criterion 4c)', (tester) async {
    stored = ParentalSettings(timerDisabled: true);
    premium(false);
    await pumpSection(tester);

    expect(find.byKey(const ValueKey<String>('games-no-time')), findsNothing);
    expect(stored.timerDisabled, isFalse);
  });

  testWidgets('keep the stars is free, and turning it off restarts the grace (HU-016 R2, R3, R6)', (tester) async {
    await pumpSection(tester);

    final Finder keep = find.byKey(const ValueKey<String>('games-keep-stars'));
    expect(tester.widget<SwitchListTile>(keep).onChanged, isNotNull);
    expect(find.text(l10n.parentsZoneKeepStarsHint), findsOneWidget);

    await tester.tap(keep);
    await tester.pump();
    expect(stored.keepStars, isTrue);
    expect(stored.starDecayResumedAt, isNull);

    await tester.tap(keep);
    await tester.pump();
    expect(stored.keepStars, isFalse);
    expect(stored.starDecayResumedAt, isNotNull);
  });

  testWidgets('shows nothing without a repository', (tester) async {
    await tester.pumpWidget(localizedApp(home: const Scaffold(body: ParentsGamesSection())));
    expect(find.byKey(const ValueKey<String>('parents-zone-games')), findsNothing);
  });

  group('GameSettingsCubit', () {
    test('ignores repeated values and the switch without Premium', () async {
      final cubit = GameSettingsCubit(repository: repository);
      await cubit.load();

      await cubit.setRound(GameId.memory, GameDifficulty.easy);
      await cubit.setTimerDisabled(true);

      verifyNever(() => repository.updateParentalSettings(any()));
      verifyNever(() => repository.saveGameProgress(any(), any()));
      expect(cubit.state.timerDisabled, isFalse);
      await cubit.close();
    });

    test('a failure reading leaves the defaults; a failure saving keeps the screen working', () async {
      when(() => repository.readParentalSettings()).thenThrow(StateError('disk'));
      final cubit = GameSettingsCubit(repository: repository);
      final errors = <Object>[];
      cubit.stream.listen((_) {}, onError: errors.add);

      await cubit.load();
      expect(cubit.state, const GameSettingsState(loaded: true));

      when(() => repository.saveGameProgress(any(), any())).thenThrow(StateError('full'));
      await cubit.setRound(GameId.shadows, GameDifficulty.normal);
      expect(cubit.state.rounds[GameId.shadows], GameDifficulty.normal);
      await cubit.close();
    });

    test('state equality by value', () {
      const a = GameSettingsState(loaded: true, isPremium: true);
      expect(a, const GameSettingsState(loaded: true, isPremium: true));
      expect(a.hashCode, const GameSettingsState(loaded: true, isPremium: true).hashCode);
      expect(a, isNot(a.copyWith(rounds: const {GameId.memory: GameDifficulty.normal})));
    });
  });

  testWidgets('the section uses its own cubit from the repository', (tester) async {
    await pumpSection(tester);
    expect(tester.element(find.byKey(const ValueKey<String>('parents-zone-games'))).read<GameSettingsCubit>(),
        isA<GameSettingsCubit>());
  });
}
