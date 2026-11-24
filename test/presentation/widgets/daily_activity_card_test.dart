import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/activities/activity.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/screens/main_menu_screen.dart';

import '../activities_test_support.dart';
import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

/// HU-047 D1, D2, P13: la idea del día y el acceso a la sección en el menú.
void main() {
  setUpAll(registerMemoryGameFallbacks);
  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  final ActivityLibrary library = sampleActivityLibrary();
  final DateTime monday = DateTime(2026, 11, 23, 10);
  final DateTime tuesday = DateTime(2026, 11, 24, 8);

  late MockPersistenceRepository repository;
  UserProfile? saved;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    saved = null;
    // Como el repositorio real: lee lo último guardado.
    when(() => repository.readUserProfile())
        .thenAnswer((_) async => saved ?? const UserProfile(isPremium: false, isSoundEnabled: true));
    when(() => repository.saveUserProfile(any())).thenAnswer((invocation) async {
      saved = invocation.positionalArguments.single as UserProfile;
    });
  });

  tearDown(() => MainMenuScreen.clock = DateTime.now);

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// El menú en un teléfono en vertical, el día [day].
  Future<void> pumpMenu(WidgetTester tester, DateTime day) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    MainMenuScreen.clock = () => day;
    await tester.pumpWidget(localizedApp(
      repository: repository,
      activities: FakeActivitySource(library),
      home: const MainMenuScreen(),
    ));
    await settle(tester);
  }

  const Key cardKey = ValueKey<String>('menu-daily-activity');
  const Key hideKey = ValueKey<String>('menu-daily-activity-hide');

  testWidgets("shows today's suggestion between the logo and the games, for the adult", (tester) async {
    await pumpMenu(tester, monday);
    final Activity today = library.suggestionFor(monday)!;

    expect(find.text(l10n.activitiesDailyTitle), findsOneWidget);
    expect(l10n.activitiesDailyTitle, 'Idea para hoy, sin pantallas');
    expect(find.text('${today.title} · ${l10n.activitiesMinutes(today.minutes)}'), findsOneWidget);
    final Rect card = tester.getRect(find.byKey(cardKey));
    expect(card.top, greaterThan(tester.getRect(find.byKey(const ValueKey<String>('menu-logo'))).bottom));
    expect(card.bottom, lessThan(tester.getRect(find.byKey(const ValueKey<String>('menu-game-grid'))).top));
    // Pequeña: más baja que una tarjeta de juego.
    expect(card.height, lessThan(tester.getSize(find.byKey(const ValueKey<String>('menu-memory'))).height));
  });

  testWidgets('tapping it opens its activity', (tester) async {
    await pumpMenu(tester, monday);
    final Activity today = library.suggestionFor(monday)!;

    await tester.tap(find.byKey(cardKey));
    await settle(tester);
    expect(find.byKey(ValueKey<String>('activity-screen-${today.id}')), findsOneWidget);
  });

  testWidgets('the ✕ hides it until tomorrow, and that is saved', (tester) async {
    await pumpMenu(tester, monday);

    await tester.tap(find.byKey(hideKey));
    await tester.pump();
    expect(find.byKey(cardKey), findsNothing);
    expect(saved?.activityHiddenOn, DateTime(2026, 11, 23));
    // El resto del perfil no se toca.
    expect(saved?.isSoundEnabled, isTrue);

    // Al volver a abrir la app el mismo día, sigue oculta.
    await tester.pumpWidget(const SizedBox());
    await pumpMenu(tester, DateTime(2026, 11, 23, 21));
    expect(find.byKey(cardKey), findsNothing);
    expect(find.text(l10n.activitiesTitle), findsOneWidget, reason: 'the section is still in the footer');

    // Al día siguiente vuelve, con otra sugerencia.
    await tester.pumpWidget(const SizedBox());
    await pumpMenu(tester, tuesday);
    final Activity next = library.suggestionFor(tuesday)!;
    expect(next.id, isNot(library.suggestionFor(monday)!.id));
    expect(find.byKey(cardKey), findsOneWidget);
    expect(find.text('${next.title} · ${l10n.activitiesMinutes(next.minutes)}'), findsOneWidget);
  });

  testWidgets('the footer button opens the section, next to the parents zone and exit', (tester) async {
    await pumpMenu(tester, monday);
    final Finder button = find.byKey(const ValueKey<String>('menu-activities'));
    expect(find.descendant(of: button, matching: find.text(l10n.activitiesTitle)), findsOneWidget);
    final double row = tester.getCenter(button).dy;
    expect(tester.getCenter(find.byKey(const ValueKey<String>('menu-parents-zone'))).dy,
        moreOrLessEquals(row, epsilon: 60));

    await tester.tap(button);
    await settle(tester);
    expect(find.byKey(const ValueKey<String>('activities-screen')), findsOneWidget);
  });

  testWidgets('without activities to show, the card takes no space', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    MainMenuScreen.clock = () => monday;
    await tester.pumpWidget(localizedApp(
      repository: repository,
      activities: FakeActivitySource(ActivityLibrary(activities: const [], searchHints: const [], noResults: '')),
      home: const MainMenuScreen(),
    ));
    await settle(tester);
    expect(find.byKey(cardKey), findsNothing);
  });
}
