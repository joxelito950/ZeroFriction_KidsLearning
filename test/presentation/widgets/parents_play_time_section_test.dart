import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/parental/daily_play_time.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/play_time/play_time_cubit.dart';
import 'package:toddler_logic/presentation/widgets/parents_play_time_section.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

void main() {
  setUpAll(registerMemoryGameFallbacks);

  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  Future<PlayTimeCubit> pumpSection(WidgetTester tester, {ParentalSettings? stored}) async {
    if (stored != null) {
      when(() => repository.readParentalSettings()).thenAnswer((_) async => stored);
    }
    await tester.pumpWidget(localizedApp(
      repository: repository,
      home: const Scaffold(body: SingleChildScrollView(child: ParentsPlayTimeSection())),
    ));
    await tester.pump();
    return tester.element(find.byType(ParentsPlayTimeSection)).read<PlayTimeCubit>();
  }

  ChoiceChip chip(WidgetTester tester, String key) => tester.widget<ChoiceChip>(find.byKey(ValueKey<String>(key)));

  Finder custom() => find.byKey(const ValueKey<String>('play-time-custom-field'));

  testWidgets('shows the system controls first, then the WHO legend and the options (criterion 1)', (tester) async {
    await pumpSection(tester);

    final double system = tester.getTopLeft(find.text(l10n.parentsZonePlayTimeSystemFirst)).dy;
    final double who = tester.getTopLeft(find.text(l10n.parentsZonePlayTimeWho)).dy;
    final double options = tester.getTopLeft(find.byKey(const ValueKey<String>('play-time-limit-none'))).dy;
    expect(system, lessThan(who));
    expect(who, lessThan(options));

    expect(chip(tester, 'play-time-limit-none').selected, isTrue);
    for (final minutes in [15, 30, 45, 60, 90, 120]) {
      expect(find.text(l10n.parentsZonePlayTimeMinutes(minutes)), findsOneWidget);
    }
    expect(find.text(l10n.parentsZonePlayTimeCustom), findsOneWidget);
    expect(custom(), findsNothing);
    // Sin límite no hay contador ni tiempo extra.
    expect(find.byKey(const ValueKey<String>('play-time-extra')), findsNothing);
  });

  testWidgets('choosing a preset applies and saves it at once (R7)', (tester) async {
    final PlayTimeCubit cubit = await pumpSection(tester);

    await tester.tap(find.byKey(const ValueKey<String>('play-time-limit-30')));
    await tester.pump();

    expect(cubit.state.limitMinutes, 30);
    expect(chip(tester, 'play-time-limit-30').selected, isTrue);
    expect(chip(tester, 'play-time-limit-none').selected, isFalse);
    expect(find.text(l10n.parentsZonePlayTimeToday(0, 30)), findsOneWidget);
    verify(() => repository.saveParentalSettings(any())).called(greaterThanOrEqualTo(1));

    await tester.tap(find.byKey(const ValueKey<String>('play-time-limit-none')));
    await tester.pump();
    expect(cubit.state.limitMinutes, isNull);
  });

  testWidgets('a custom value outside 5 minutes to 12 hours is not accepted; 25 is (criterion 2)', (tester) async {
    final PlayTimeCubit cubit = await pumpSection(tester);

    await tester.tap(find.byKey(const ValueKey<String>('play-time-limit-custom')));
    await tester.pump();
    expect(custom(), findsOneWidget);
    expect(find.text(l10n.parentsZonePlayTimeCustomRange), findsOneWidget);

    Future<void> apply(String text) async {
      await tester.enterText(custom(), text);
      await tester.tap(find.byKey(const ValueKey<String>('play-time-custom-apply')));
      await tester.pump();
    }

    TextStyle rangeStyle() => tester.widget<Text>(find.byKey(const ValueKey<String>('play-time-custom-range'))).style!;

    await apply('3');
    expect(cubit.state.limitMinutes, isNull);
    expect(rangeStyle().fontWeight, FontWeight.bold);

    await apply('800');
    expect(cubit.state.limitMinutes, isNull);

    await apply('');
    expect(cubit.state.limitMinutes, isNull);

    await apply('25');
    expect(cubit.state.limitMinutes, 25);
    expect(rangeStyle().fontWeight, FontWeight.normal);
    expect(chip(tester, 'play-time-limit-custom').selected, isTrue);
  });

  testWidgets('only digits can be typed, and Enter applies the value', (tester) async {
    final PlayTimeCubit cubit = await pumpSection(tester);
    await tester.tap(find.byKey(const ValueKey<String>('play-time-limit-custom')));
    await tester.pump();

    await tester.enterText(custom(), '4a0');
    expect(tester.widget<TextField>(custom()).controller!.text, '40');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(cubit.state.limitMinutes, 40);
  });

  testWidgets('a stored custom limit shows the custom field filled in', (tester) async {
    await pumpSection(tester, stored: ParentalSettings(dailyLimitMinutes: 25));

    expect(chip(tester, 'play-time-limit-custom').selected, isTrue);
    expect(custom(), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('play-time-limit-custom')));
    await tester.pump();
    expect(tester.widget<TextField>(custom()).controller!.text, '25');
  });

  testWidgets('shows today\'s minutes and gives 15 more (R6)', (tester) async {
    final PlayTimeCubit cubit = await pumpSection(
      tester,
      stored: ParentalSettings(
        dailyLimitMinutes: 30,
        playTime: DailyPlayTime(day: DateTime.now(), played: const Duration(minutes: 30)),
      ),
    );
    expect(find.text(l10n.parentsZonePlayTimeToday(30, 30)), findsOneWidget);
    expect(cubit.state.limitReached, isTrue);

    await tester.tap(find.byKey(const ValueKey<String>('play-time-extra')));
    await tester.pump();

    expect(cubit.state.limitReached, isFalse);
    expect(find.text(l10n.parentsZonePlayTimeToday(30, 45)), findsOneWidget);
  });

  testWidgets('shows nothing without the play time cubit', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: ParentsPlayTimeSection()),
    ));

    expect(find.byKey(const ValueKey<String>('parents-zone-play-time')), findsNothing);
  });
}
