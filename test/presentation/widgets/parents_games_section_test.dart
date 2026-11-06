import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/game_settings/game_settings_cubit.dart';
import 'package:toddler_logic/presentation/widgets/parents_games_section.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

/// Sección «Juegos» de la Zona de Padres (HU-030 3.1).
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

  ChoiceChip chip(WidgetTester tester, GameDifficulty difficulty) =>
      tester.widget<ChoiceChip>(find.byKey(ValueKey<String>('difficulty-${difficulty.name}')));

  SwitchListTile noTime(WidgetTester tester) =>
      tester.widget<SwitchListTile>(find.byKey(const ValueKey<String>('games-no-time')));

  testWidgets('starts in Normal with time (criterion 1)', (tester) async {
    await pumpSection(tester);

    expect(find.text(l10n.parentsZoneGamesTitle), findsOneWidget);
    expect(chip(tester, GameDifficulty.normal).selected, isTrue);
    expect(find.text(l10n.difficultyNormalHint), findsOneWidget);
    expect(noTime(tester).value, isFalse);
  });

  testWidgets('choosing a difficulty saves it and explains it', (tester) async {
    await pumpSection(tester);

    await tester.tap(find.byKey(const ValueKey<String>('difficulty-impossible')));
    await tester.pump();

    expect(chip(tester, GameDifficulty.impossible).selected, isTrue);
    expect(find.text(l10n.difficultyImpossibleHint), findsOneWidget);
    expect(stored.difficulty, GameDifficulty.impossible);

    await tester.tap(find.byKey(const ValueKey<String>('difficulty-easy')));
    await tester.pump();
    expect(find.text(l10n.difficultyEasyHint), findsOneWidget);
    expect(stored.difficulty, GameDifficulty.easy);
  });

  testWidgets('without Premium the switch is locked and says why (R4, criterion 4b)', (tester) async {
    await pumpSection(tester);

    expect(noTime(tester).onChanged, isNull);
    expect(find.textContaining(l10n.parentsZonePremiumOnly), findsOneWidget);
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

    expect(noTime(tester).value, isFalse);
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

      await cubit.setDifficulty(GameDifficulty.normal);
      await cubit.setTimerDisabled(true);

      verifyNever(() => repository.updateParentalSettings(any()));
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

      when(() => repository.updateParentalSettings(any())).thenThrow(StateError('full'));
      await cubit.setDifficulty(GameDifficulty.easy);
      expect(cubit.state.difficulty, GameDifficulty.easy);
      await cubit.close();
    });

    test('state equality by value', () {
      const a = GameSettingsState(loaded: true, isPremium: true);
      expect(a, const GameSettingsState(loaded: true, isPremium: true));
      expect(a.hashCode, const GameSettingsState(loaded: true, isPremium: true).hashCode);
      expect(a, isNot(a.copyWith(difficulty: GameDifficulty.easy)));
    });
  });

  testWidgets('the section uses its own cubit from the repository', (tester) async {
    await pumpSection(tester);
    expect(tester.element(find.byKey(const ValueKey<String>('parents-zone-games'))).read<GameSettingsCubit>(),
        isA<GameSettingsCubit>());
  });
}
