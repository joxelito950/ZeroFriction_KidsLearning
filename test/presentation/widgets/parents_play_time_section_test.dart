import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/parental/daily_play_time.dart';
import 'package:toddler_logic/domain/parental/rest_schedule.dart';
import 'package:toddler_logic/presentation/widgets/parents_bedtime_editor.dart';
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

  // Visto en el moto g55 (2026-11-16): el teclado tapaba «Guardar».
  testWidgets('Save stays above the keyboard', (tester) async {
    await pumpPage(tester);
    await tap(tester, 'play-time-limit-custom');
    await tester.enterText(custom(), '25');
    tester.view.viewInsets = const FakeViewPadding(bottom: 900);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();

    final double keyboardTop =
        tester.view.physicalSize.height / tester.view.devicePixelRatio - 900 / tester.view.devicePixelRatio;
    expect(tester.getBottomLeft(saveButton()).dy, lessThanOrEqualTo(keyboardTop));
    expect(saveButton().hitTestable(), findsOneWidget);
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

  group('bedtime and naps (HU-038 §3.1)', () {
    Finder key(String name) => find.byKey(ValueKey<String>(name));
    String time(WidgetTester tester, int minute) => formatDayMinute(tester.element(page()), minute);

    // La pantalla ya es larga: hay que dejar que el desplazamiento se pinte antes de tocar.
    Future<void> tapKey(WidgetTester tester, String name) async {
      await tester.ensureVisible(key(name));
      await tester.pump();
      await tester.tap(key(name));
      await tester.pump();
    }

    testWidgets('system first, then the WHO sleep advice, then the app switch, off by default', (tester) async {
      await pumpPage(tester);
      await tester.ensureVisible(key('naps-enable'));
      final double system = tester.getTopLeft(find.text(l10n.parentsBedtimeSystem)).dy;
      final double who = tester.getTopLeft(find.text(l10n.parentsBedtimeWho)).dy;
      final double toggle = tester.getTopLeft(key('bedtime-enable')).dy;
      expect(system, lessThan(who));
      expect(who, lessThan(toggle));
      expect(tester.widget<SwitchListTile>(key('bedtime-enable')).value, isFalse);
      expect(key('bedtime-from'), findsNothing);
      expect(key('nap-add'), findsNothing);
    });

    testWidgets('turning it on proposes 19:30 to 7:00 in the phone format, and «Save» applies it (P1)', (tester) async {
      final PlayTimeCubit cubit = await pumpPage(tester);
      await tapKey(tester, 'bedtime-enable');
      expect(find.text(l10n.parentsBedtimeSummary(time(tester, 1170), time(tester, 420))), findsOneWidget);
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNotNull);
      await save(tester);
      expect(cubit.state.schedule, const RestSchedule(night: RestSchedule.defaultNight));
      expect(page(), findsNothing);
    });

    testWidgets('24-hour phones see 24-hour times', (tester) async {
      tester.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      addTearDown(tester.platformDispatcher.clearAlwaysUse24HourTestValue);
      await pumpPage(tester);
      await tapKey(tester, 'bedtime-enable');
      expect(find.textContaining('19:30'), findsWidgets);
    });

    testWidgets('naps: the first at 13:00, a second where it fits, and it can be removed (P6)', (tester) async {
      final PlayTimeCubit cubit = await pumpPage(tester);
      await tapKey(tester, 'bedtime-enable');
      await tapKey(tester, 'naps-enable');
      expect(find.text(l10n.parentsNapLabel(1)), findsOneWidget);
      expect(find.textContaining(time(tester, 13 * 60)), findsOneWidget);
      await tapKey(tester, 'nap-add');
      expect(find.text(l10n.parentsNapLabel(2)), findsOneWidget);
      expect(find.textContaining(time(tester, 9 * 60)), findsOneWidget);
      expect(key('nap-add'), findsNothing, reason: 'two at most');
      await tapKey(tester, 'nap-1-remove');
      expect(find.text(l10n.parentsNapLabel(2)), findsNothing);
      await tapKey(tester, 'nap-add');
      await save(tester);
      expect(cubit.state.schedule.naps, [RestSchedule.defaultNap, RestWindow(9 * 60, 10 * 60)]);
    });

    testWidgets('turning naps or bedtime off clears them', (tester) async {
      final PlayTimeCubit cubit = await pumpPage(
        tester,
        stored: ParentalSettings(
            restSchedule: const RestSchedule(night: RestSchedule.defaultNight, naps: [RestSchedule.defaultNap])),
      );
      await tapKey(tester, 'naps-enable');
      await tapKey(tester, 'bedtime-enable');
      await save(tester);
      expect(cubit.state.schedule, RestSchedule.off);
    });

    testWidgets('a time picked in the system picker changes the draft; cancelling keeps it', (tester) async {
      tester.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      addTearDown(tester.platformDispatcher.clearAlwaysUse24HourTestValue);
      // Un teléfono en vertical: el selector en modo teclado no cabe en 800 × 600.
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await pumpPage(tester,
          stored: ParentalSettings(
              restSchedule: const RestSchedule(night: RestSchedule.defaultNight, naps: [RestSchedule.defaultNap])));

      Future<void> pick(String button, String hour, String minute) async {
        await tapKey(tester, button);
        await tester.pump(const Duration(milliseconds: 500));
        await tester.tap(find.byIcon(Icons.keyboard_outlined));
        await tester.pump(const Duration(milliseconds: 500));
        final Finder fields = find.descendant(of: find.byType(Dialog), matching: find.byType(TextField));
        await tester.enterText(fields.at(0), hour);
        await tester.enterText(fields.at(1), minute);
        await tester.tap(find.text(MaterialLocalizations.of(tester.element(page())).okButtonLabel));
        await tester.pump(const Duration(milliseconds: 500));
      }

      await pick('bedtime-from', '20', '00');
      await pick('bedtime-until', '06', '30');
      await pick('nap-0-from', '12', '30');
      await pick('nap-0-until', '14', '00');
      expect(find.text(l10n.parentsBedtimeSummary(time(tester, 20 * 60), time(tester, 390))), findsOneWidget);
      expect(find.textContaining('12:30'), findsOneWidget);

      // Una siesta demasiado cerca de la noche: la frase amable, y no se guarda.
      await pick('nap-0-until', '19', '00');
      expect(key('rest-problem'), findsOneWidget);
      await tester.tap(saveButton());
      await tester.pump();
      expect(page(), findsOneWidget);

      await tapKey(tester, 'bedtime-from');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(MaterialLocalizations.of(tester.element(page())).cancelButtonLabel));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(l10n.parentsBedtimeSummary(time(tester, 20 * 60), time(tester, 390))), findsOneWidget);
    });

    testWidgets('every problem has its kind sentence', (tester) async {
      for (final RestScheduleProblem problem in RestScheduleProblem.values) {
        expect(restProblemText(l10n, problem), isNotEmpty);
      }
      await tester.pumpWidget(localizedApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ParentsBedtimeEditor(schedule: RestSchedule(night: RestWindow(1200, 1200)), onChanged: (_) {}),
          ),
        ),
      ));
      expect(find.text(l10n.parentsRestProblemSameTimes), findsOneWidget);
    });

    testWidgets('the saved schedule arrives after opening: the draft follows it if untouched', (tester) async {
      await pumpPage(tester);
      final PlayTimeCubit cubit = tester.element(page()).read<PlayTimeCubit>();
      await cubit.setSchedule(const RestSchedule(night: RestSchedule.defaultNight));
      await tester.pump();
      expect(tester.widget<SwitchListTile>(key('bedtime-enable')).value, isTrue);
      expect(tester.widget<FilledButton>(saveButton()).onPressed, isNull);
    });
  });
}
