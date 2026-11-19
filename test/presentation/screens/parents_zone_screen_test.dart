import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/app_language.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/news/discovery.dart';
import 'package:toddler_logic/domain/parental/daily_play_time.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/play_time/play_time_cubit.dart';
import 'package:toddler_logic/presentation/screens/parents_zone_screen.dart';
import 'package:toddler_logic/presentation/widgets/adult_session_guard.dart';
import 'package:toddler_logic/presentation/widgets/parents_setting_page.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

/// Zona de Padres (HU-004) por filas (HU-046).
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  Future<void> pumpZone(WidgetTester tester, {ParentalSettings? settings, Locale locale = testLocale}) async {
    if (settings != null) when(() => repository.readParentalSettings()).thenAnswer((_) async => settings);
    await pumpSettingPage(tester, const ParentsZoneScreen(), repository: repository, locale: locale);
  }

  Finder row(String name) => find.byKey(ValueKey<String>('parents-row-$name'));

  Future<void> open(WidgetTester tester, String name) async {
    await tester.scrollUntilVisible(row(name), 200);
    await tester.ensureVisible(row(name));
    await tester.pump();
    await tester.tap(row(name));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> back(WidgetTester tester) async {
    tester.state<NavigatorState>(find.byType(Navigator)).maybePop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('one row per option with what is chosen, in the order of HU-046 §4.1', (tester) async {
    when(() => repository.readGameProgress(GameId.shadows))
        .thenAnswer((_) async => progressAt(2, round: GameDifficulty.gold));
    await pumpZone(tester, settings: ParentalSettings(dailyLimitMinutes: 60));

    expect(find.text(l10n.parentsZoneTitle), findsOneWidget);
    expect(find.text(l10n.parentsZoneBackToMenu), findsOneWidget);
    expect(find.descendant(of: row('language'), matching: find.text('Español')), findsOneWidget);
    expect(find.textContaining('${l10n.shadowsGameTitle}: ${l10n.roundGold}'), findsOneWidget);
    expect(find.descendant(of: row('play-time'), matching: find.text(l10n.parentsZonePlayTimePerDay(60))),
        findsOneWidget);
    // «Su progreso» va primero (HU-034 §3).
    expect(tester.getTopLeft(row('progress')).dy, lessThan(tester.getTopLeft(row('language')).dy));
    await tester.scrollUntilVisible(find.byKey(const ValueKey<String>('parents-zone-privacy')), 200);
    expect(find.text(l10n.parentsZonePinSummary), findsOneWidget);
    expect(find.text(l10n.parentsFeedbackSummary), findsOneWidget);

    final List<double> order = [
      for (final String name in ['language', 'games', 'play-time', 'pin', 'feedback'])
        tester.getTopLeft(row(name)).dy,
      tester.getTopLeft(find.byKey(const ValueKey<String>('parents-zone-privacy'))).dy,
    ];
    expect(order, [...order]..sort());
    // Nada de «próximamente» ni de compras (HU-004 P4, D-028).
    expect(find.textContaining('Próximamente'), findsNothing);
  });

  testWidgets('«Their progress» says it calmly when there is nothing to show (HU-034 §3)', (tester) async {
    await pumpZone(tester);
    expect(find.descendant(of: row('progress'), matching: find.text(l10n.parentsProgressRowEmpty)), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('parents-row-dot')), findsNothing);
  });

  testWidgets('a stuck game puts a dot on «Their progress», whose page shows the suggestion (HU-034 P8)',
      (tester) async {
    when(() => repository.readGameProgress(GameId.memory)).thenAnswer((_) async => GameProgress(
          position: const RoundPosition(round: GameDifficulty.gold, level: 4),
          stuckLevel: 4,
          stuckFalls: GameProgress.stuckThreshold,
        ));
    await pumpZone(tester);
    expect(find.descendant(of: row('progress'), matching: find.byKey(const ValueKey<String>('parents-row-dot'))),
        findsOneWidget);

    await open(tester, 'progress');
    expect(find.byKey(const ValueKey<String>('parents-zone-progress')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('progress-suggestion-memory')), findsOneWidget);
    await back(tester);
    expect(find.byKey(const ValueKey<String>('parents-zone-progress')), findsNothing);
  });

  testWidgets('after updating from rc.5, «Their progress» is New until it is opened (HU-041 R7)', (tester) async {
    UserProfile profile = UserProfile(isPremium: false, isSoundEnabled: true, discovery: Discovery.beforeNews());
    when(() => repository.readUserProfile()).thenAnswer((_) async => profile);
    when(() => repository.saveUserProfile(any())).thenAnswer((invocation) async {
      profile = invocation.positionalArguments.single as UserProfile;
    });
    await pumpZone(tester);
    expect(find.descendant(of: row('progress'), matching: find.text(l10n.newBadge)), findsOneWidget);

    await open(tester, 'progress');
    await back(tester);
    expect(find.descendant(of: row('progress'), matching: find.text(l10n.newBadge)), findsNothing);
    expect(profile.discovered.isNewFeature(ParentsFeature.progress), isFalse);
  });

  testWidgets('screen pinning opens its read-only page, without Save (HU-046 R6)', (tester) async {
    await pumpZone(tester);
    await open(tester, 'pin');

    final Finder page = find.byKey(const ValueKey<String>('parents-zone-screen-pinning'));
    expect(page, findsOneWidget);
    expect(find.text(l10n.parentsZonePinTitle), findsOneWidget, reason: 'in the app bar');
    for (final step in ['1', '2', '3']) {
      expect(find.descendant(of: page, matching: find.text(step)), findsOneWidget);
    }
    expect(find.text(l10n.parentsZonePinNote), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('parents-setting-save')), findsNothing);

    await back(tester);
    expect(row('pin'), findsOneWidget);
  });

  testWidgets('the language page applies the chosen language at once and goes back (HU-046 P2)', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpZone(tester);
    await open(tester, 'language');

    for (final code in AppLanguage.supported) {
      final tile = find.byKey(ValueKey<String>('language-$code'));
      await tester.scrollUntilVisible(tile, 100);
      expect(find.descendant(of: tile, matching: find.text(AppLanguage.nativeNames[code]!)), findsOneWidget);
      expect(tester.widget<ListTile>(tile).selected, code == 'es', reason: code);
    }
    expect(find.bySemanticsLabel('العربية'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('parents-setting-save')), findsNothing);

    await tester.ensureVisible(find.byKey(const ValueKey<String>('language-ar')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('language-ar')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey<String>('language-ar')), findsNothing, reason: 'back in the zone');
    semantics.dispose();
  });

  testWidgets('the games and play time rows open their pages, one level deep (HU-046 R4)', (tester) async {
    await pumpZone(tester);
    await open(tester, 'games');
    expect(find.byKey(const ValueKey<String>('parents-zone-games')), findsOneWidget);
    expect(find.byType(ParentsSettingRow), findsNothing, reason: 'no rows inside a settings page');
    await back(tester);

    await open(tester, 'play-time');
    expect(find.byKey(const ValueKey<String>('parents-zone-play-time')), findsOneWidget);
    await back(tester);

    await open(tester, 'feedback');
    expect(find.text(l10n.parentsFeedbackTitle), findsOneWidget);
  });

  testWidgets('a round saved in the games page shows in the row summary', (tester) async {
    await pumpZone(tester);
    await open(tester, 'games');
    await tester.tap(find.byKey(const ValueKey<String>('round-memory-gold')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('parents-setting-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('${l10n.menuMemoryTitle}: ${l10n.roundGold}'), findsOneWidget);
  });

  group('15 more minutes at the top (HU-046 §4.1)', () {
    Finder extra() => find.byKey(const ValueKey<String>('play-time-extra'));

    testWidgets('not shown while the child can still play', (tester) async {
      await pumpZone(tester, settings: ParentalSettings(dailyLimitMinutes: 30));
      expect(extra(), findsNothing);
    });

    testWidgets('shown when today is over, and it gives 15 more minutes', (tester) async {
      await pumpZone(
        tester,
        settings: ParentalSettings(
          dailyLimitMinutes: 30,
          playTime: DailyPlayTime(day: DateTime.now(), played: const Duration(minutes: 30)),
        ),
      );
      expect(extra(), findsOneWidget);
      expect(tester.getTopLeft(extra()).dy, lessThan(tester.getTopLeft(row('language')).dy));

      await tester.tap(extra());
      await tester.pump();
      final PlayTimeCubit cubit = tester.element(find.byType(ParentsZoneScreen)).read<PlayTimeCubit>();
      expect(cubit.state.limitReached, isFalse);
      expect(extra(), findsNothing);
    });
  });

  group('privacy (HU-014 R5, criterio 3)', () {
    Future<Finder> openPrivacy(WidgetTester tester, {Locale locale = testLocale}) async {
      await pumpZone(tester, locale: locale);
      final toggle = find.byKey(const ValueKey<String>('parents-zone-privacy-toggle'));
      await tester.scrollUntilVisible(toggle, 200);
      await tester.ensureVisible(toggle);
      await tester.pump();
      await tester.tap(toggle);
      await tester.pump(const Duration(milliseconds: 300)); // animación de la sección
      // El asset se lee con E/S real, que el reloj falso del test no espera.
      final policy = find.byKey(const ValueKey<String>('parents-zone-privacy-policy'), skipOffstage: false);
      for (var attempt = 0; attempt < 50 && policy.evaluate().isEmpty; attempt++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
        await tester.pump();
      }
      return policy;
    }

    testWidgets('shows a summary and hides the policy until it is opened', (tester) async {
      await pumpZone(tester);
      await tester.scrollUntilVisible(find.byKey(const ValueKey<String>('parents-zone-privacy')), 200);

      expect(find.text('Privacidad'), findsOneWidget);
      expect(find.text('ToddlerLogic no recopila datos: todo permanece en este teléfono.'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('parents-zone-privacy-policy')), findsNothing);
    });

    testWidgets('opens the full policy in Spanish', (tester) async {
      final Finder policy = await openPrivacy(tester);

      expect(find.descendant(of: policy, matching: find.text('Política de privacidad de ToddlerLogic', skipOffstage: false)), findsOneWidget);
    });

    testWidgets('falls back to the English policy for a language without its own (P7)', (tester) async {
      final Finder policy = await openPrivacy(tester, locale: const Locale('fr'));

      expect(find.text('Confidentialité'), findsOneWidget);
      expect(find.descendant(of: policy, matching: find.text('ToddlerLogic Privacy Policy', skipOffstage: false)), findsOneWidget);
    });
  });

  testWidgets('is protected by the adult session guard (R7), also on its pages (HU-046 R5)', (tester) async {
    await pumpZone(tester);
    expect(find.byType(AdultSessionGuard), findsOneWidget);
    await open(tester, 'play-time');
    expect(find.byType(AdultSessionGuard, skipOffstage: false), findsNWidgets(2));
  });

  testWidgets('a page in use keeps the session open; one minute idle on it closes everything (HU-046 R5)',
      (tester) async {
    await pumpZone(tester);
    await open(tester, 'play-time');

    // El adulto toca la pantalla de configuración durante más de un minuto.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 20));
      await tester.tap(find.byKey(const ValueKey<String>('play-time-limit-15')));
      await tester.pump();
    }
    expect(find.byType(ParentsZoneScreen, skipOffstage: false), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('parents-zone-play-time')), findsOneWidget);

    // Un minuto sin tocar: todo se cierra y el borrador no se aplica.
    await tester.pump(AdultSessionGuard.defaultInactivity);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ParentsZoneScreen, skipOffstage: false), findsNothing);
    expect(tester.element(find.text('open setting page')).read<PlayTimeCubit>().state.limitMinutes, isNull);
  });

  // Visto en el moto g55 (2026-11-16): al volver de una pantalla usada durante
  // casi un minuto, la Zona de Padres se cerraba enseguida.
  testWidgets('coming back from a page in use gives the zone a full minute again', (tester) async {
    await pumpZone(tester);
    await open(tester, 'play-time'); // el minuto de la Zona de Padres empieza aquí
    // Unos 50 s usando la pantalla, sin cambiar nada, y se vuelve poco antes de
    // que venza el minuto de la Zona de Padres, que no ve estos toques.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 10));
      await tester.tap(find.byKey(const ValueKey<String>('play-time-limit-none')));
      await tester.pump();
    }
    await back(tester);

    await tester.pump(const Duration(seconds: 20));
    await tester.pump(const Duration(milliseconds: 500)); // por si se estuviera cerrando
    expect(find.byType(ParentsZoneScreen), findsOneWidget, reason: 'the last touch was 20 s ago');
    await tester.pump(const Duration(seconds: 45));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ParentsZoneScreen), findsNothing, reason: 'one minute without touching anything');
  });

  testWidgets('without a repository there is no games row', (tester) async {
    await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));
    expect(row('games'), findsNothing);
    expect(row('language'), findsOneWidget);
  });
}
