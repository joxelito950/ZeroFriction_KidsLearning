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

/// Pantalla «Tiempo de juego» (HU-009, HU-046): se elige un borrador y se
/// aplica con «Guardar».
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  Finder page() => find.byType(ParentsPlayTimePage);
  Finder custom() => find.byKey(const ValueKey<String>('play-time-custom-field'));
  Finder saveButton() => find.byKey(const ValueKey<String>('parents-setting-save'));

  Future<PlayTimeCubit> pumpPage(WidgetTester tester, {ParentalSettings? stored}) async {
    if (stored != null) {
      when(() => repository.readParentalSettings()).thenAnswer((_) async => stored);
    }
    await pumpSettingPage(tester, const ParentsPlayTimePage(), repository: repository);
    return tester.element(page()).read<PlayTimeCubit>();
  }

  ChoiceChip chip(WidgetTester tester, String key) => tester.widget<ChoiceChip>(find.byKey(ValueKey<String>(key)));

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(ValueKey<String>(key)));
    await tester.tap(find.byKey(ValueKey<String>(key)));
    await tester.pump();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> save(WidgetTester tester) async {
    await tester.tap(saveButton());
    await settle(tester);
  }

  testWidgets('shows the system controls first, then the WHO legend and the options (criterion 1)', (tester) async {
    await pumpPage(tester);

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
    // «15 minutos más» ya no está aquí: va arriba de la Zona de Padres (HU-046).
    expect(find.byKey(const ValueKey<String>('play-time-extra')), findsNothing);
    expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull, reason: 'nothing changed yet');
  });

  testWidgets('a preset is applied only with Save, which goes back (HU-046 R2)', (tester) async {
    final PlayTimeCubit cubit = await pumpPage(tester);

    await tap(tester, 'play-time-limit-30');
    expect(chip(tester, 'play-time-limit-30').selected, isTrue);
    expect(cubit.state.limitMinutes, isNull);

    await save(tester);
    expect(cubit.state.limitMinutes, 30);
    expect(page(), findsNothing);
    verify(() => repository.saveParentalSettings(any())).called(greaterThanOrEqualTo(1));
  });

  testWidgets('a custom value outside 5 minutes to 12 hours is not saved and the page stays; 25 is (criterion 2)',
      (tester) async {
    final PlayTimeCubit cubit = await pumpPage(tester);

    await tap(tester, 'play-time-limit-custom');
    expect(custom(), findsOneWidget);
    expect(find.text(l10n.parentsZonePlayTimeCustomRange), findsOneWidget);

    TextStyle rangeStyle() => tester.widget<Text>(find.byKey(const ValueKey<String>('play-time-custom-range'))).style!;

    for (final text in ['3', '800']) {
      await tester.enterText(custom(), text);
      await tester.pump();
      await save(tester);
      expect(cubit.state.limitMinutes, isNull, reason: text);
      expect(page(), findsOneWidget);
      expect(rangeStyle().fontWeight, FontWeight.bold);
    }

    await tester.enterText(custom(), '25');
    await tester.pump();
    expect(rangeStyle().fontWeight, FontWeight.normal, reason: 'typing again clears the highlight');
    await save(tester);
    expect(cubit.state.limitMinutes, 25);
  });

  testWidgets('only digits can be typed', (tester) async {
    await pumpPage(tester);
    await tap(tester, 'play-time-limit-custom');

    await tester.enterText(custom(), '4a0');
    expect(tester.widget<TextField>(custom()).controller!.text, '40');
  });

  testWidgets('a stored custom limit shows the custom field filled in', (tester) async {
    await pumpPage(tester, stored: ParentalSettings(dailyLimitMinutes: 25));

    expect(chip(tester, 'play-time-limit-custom').selected, isTrue);
    expect(tester.widget<TextField>(custom()).controller!.text, '25');
    expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);

    // Volver a una opción fija y otra vez a «Personalizado» conserva lo escrito.
    await tap(tester, 'play-time-limit-60');
    await tap(tester, 'play-time-limit-custom');
    expect(tester.widget<TextField>(custom()).controller!.text, '25');
  });

  testWidgets('shows the minutes played today with a limit', (tester) async {
    await pumpPage(
      tester,
      stored: ParentalSettings(
        dailyLimitMinutes: 30,
        playTime: DailyPlayTime(day: DateTime.now(), played: const Duration(minutes: 12)),
      ),
    );
    expect(find.text(l10n.parentsZonePlayTimeToday(12, 30)), findsOneWidget);
  });

  group('leaving with changes (HU-046 R3)', () {
    Future<void> back(WidgetTester tester) async {
      final NavigatorState navigator = tester.state(find.byType(Navigator));
      navigator.maybePop();
      await settle(tester);
    }

    testWidgets('without changes it just goes back', (tester) async {
      await pumpPage(tester);
      await back(tester);
      expect(find.byKey(const ValueKey<String>('parents-unsaved-dialog')), findsNothing);
      expect(page(), findsNothing);
    });

    testWidgets('Discard leaves without applying', (tester) async {
      final PlayTimeCubit cubit = await pumpPage(tester);
      await tap(tester, 'play-time-limit-45');
      await back(tester);

      expect(find.text(l10n.parentsUnsavedTitle), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('parents-unsaved-discard')));
      await settle(tester);
      expect(page(), findsNothing);
      expect(cubit.state.limitMinutes, isNull);
    });

    testWidgets('Save applies and leaves; an invalid value keeps the page open', (tester) async {
      final PlayTimeCubit cubit = await pumpPage(tester);
      await tap(tester, 'play-time-limit-custom');
      await tester.enterText(custom(), '2');
      await tester.pump();
      await tester.pump();
      await back(tester);
      await tester.tap(find.byKey(const ValueKey<String>('parents-unsaved-save')));
      await settle(tester);
      expect(page(), findsOneWidget);
      expect(cubit.state.limitMinutes, isNull);

      await tester.enterText(custom(), '20');
      await tester.pump();
      await tester.pump();
      await back(tester);
      await tester.tap(find.byKey(const ValueKey<String>('parents-unsaved-save')));
      await settle(tester);
      expect(page(), findsNothing);
      expect(cubit.state.limitMinutes, 20);
    });

    testWidgets('closing the dialog without choosing stays on the page', (tester) async {
      await pumpPage(tester);
      await tap(tester, 'play-time-limit-45');
      await back(tester);
      await tester.tapAt(const Offset(5, 5)); // fuera del diálogo
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(page(), findsOneWidget);
    });
  });

  test('the row summary says the daily limit or no limit', () {
    expect(parentsPlayTimeSummary(l10n, null), l10n.parentsZonePlayTimeNoLimit);
    expect(parentsPlayTimeSummary(l10n, 60), l10n.parentsZonePlayTimePerDay(60));
  });
}
