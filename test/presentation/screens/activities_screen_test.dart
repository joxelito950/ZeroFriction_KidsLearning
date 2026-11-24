import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/activities/activity.dart';
import 'package:toddler_logic/domain/parental/rest_schedule.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/play_time/play_time_cubit.dart';
import 'package:toddler_logic/presentation/screens/activities_screen.dart';
import 'package:toddler_logic/presentation/screens/activity_screen.dart';
import 'package:toddler_logic/presentation/screens/rest_screen.dart';
import 'package:toddler_logic/presentation/theme/app_palette.dart';

import '../activities_test_support.dart';
import '../l10n_test_support.dart';

/// HU-047, entrega 2: la sección «Actividades sin pantallas», la pantalla de
/// cada actividad y el acceso desde la pantalla de descanso.
void main() {
  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  final ActivityLibrary library = sampleActivityLibrary();

  Future<void> settle(WidgetTester tester) async {
    // Sin pumpAndSettle: el tiempo de juego emite cada segundo y no se asienta.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  /// Abre [screen] encima de otra ruta, como en la app. Salvo con [tall] en
  /// `false`, en una pantalla muy alta: se ven todas las tarjetas a la vez.
  Future<void> open(WidgetTester tester, Widget screen, {FakeActivitySource? source, bool tall = true}) async {
    if (tall) {
      tester.view.physicalSize = const Size(1440, 9000);
      addTearDown(tester.view.reset);
    }
    await tester.pumpWidget(localizedApp(
      activities: source ?? FakeActivitySource(library),
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen)),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await settle(tester);
  }

  Finder card(String id) => find.byKey(ValueKey<String>('activity-card-$id'));

  Iterable<String> shownIds(WidgetTester tester) => tester
      .widgetList(find.byWidgetPredicate((widget) =>
          widget.key is ValueKey<String> && (widget.key! as ValueKey<String>).value.startsWith('activity-card-')))
      .map((widget) => (widget.key! as ValueKey<String>).value.replaceFirst('activity-card-', ''));

  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(target, 120, scrollable: find.byType(Scrollable).last);
    await tester.pump();
  }

  group('the section', () {
    testWidgets('shows the general warning, the guiding search field, the hints and every activity', (tester) async {
      final FakeActivitySource source = FakeActivitySource(library);
      await open(tester, const ActivitiesScreen(), source: source);

      expect(find.text(l10n.activitiesTitle), findsOneWidget);
      expect(source.loadedLanguages, ['es'], reason: 'the content is in the app language');
      expect(find.text(l10n.activitiesSafetyWarning), findsOneWidget);
      final TextField field = tester.widget<TextField>(find.byKey(const ValueKey<String>('activities-search')));
      expect(field.decoration?.hintText, l10n.activitiesSearchLabel);
      expect(l10n.activitiesSearchLabel, 'Busca por material, por lo que le gusta o por una idea');
      for (final String hint in library.searchHints) {
        expect(find.widgetWithText(ActionChip, hint), findsOneWidget);
      }
      for (final ActivityCategory category in ActivityCategory.values) {
        expect(find.byKey(ValueKey<String>('activities-category-${category.name}')), findsOneWidget);
      }
      expect(find.text('Hasta 5 min'), findsOneWidget);
      expect(find.text('Hasta 30 min'), findsOneWidget);
      expect(find.text(l10n.activitiesCount(7)), findsOneWidget);
      expect(shownIds(tester), library.activities.map((activity) => activity.id));
      // Cada tarjeta: título, categoría y minutos, y los primeros materiales.
      expect(find.descendant(of: card('art-water'), matching: find.text('Pintar con agua')), findsOneWidget);
      expect(find.descendant(of: card('art-water'), matching: find.text('Arte · 30 min')), findsOneWidget);
      expect(find.descendant(of: card('art-water'), matching: find.text('Brocha · Agua · Vaso')), findsOneWidget);
    });

    testWidgets('searches while typing, without accents or capitals, and clears', (tester) async {
      await open(tester, const ActivitiesScreen());

      await tester.enterText(find.byKey(const ValueKey<String>('activities-search')), 'COJIN');
      await tester.pump();
      expect(shownIds(tester), ['search-soft', 'move-cushions']);
      expect(find.text(l10n.activitiesCount(2)), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('activities-search-clear')));
      await tester.pump();
      expect(find.text(l10n.activitiesCount(7)), findsOneWidget);
    });

    testWidgets('a hint chip searches its text', (tester) async {
      await open(tester, const ActivitiesScreen());

      await tester.tap(find.widgetWithText(ActionChip, 'día de lluvia'));
      await tester.pump();
      expect(tester.widget<TextField>(find.byKey(const ValueKey<String>('activities-search'))).controller?.text,
          'día de lluvia');
      expect(shownIds(tester), ['search-red', 'move-cushions']);
      expect(find.text(l10n.activitiesCount(2)), findsOneWidget);
    });

    testWidgets('category and time chips filter, one at a time, and toggle off', (tester) async {
      await open(tester, const ActivitiesScreen());
      final Finder search = find.byKey(const ValueKey<String>('activities-category-search'));
      final Finder art = find.byKey(const ValueKey<String>('activities-category-art'));

      await tester.tap(search);
      await tester.pump();
      expect(shownIds(tester), ['search-red', 'search-soft']);
      expect(tester.widget<ChoiceChip>(search).selected, isTrue);

      await tester.tap(art);
      await tester.pump();
      expect(shownIds(tester), ['art-water']);
      expect(tester.widget<ChoiceChip>(search).selected, isFalse);

      await tester.tap(art);
      await tester.pump();
      expect(find.text(l10n.activitiesCount(7)), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('activities-minutes-5')));
      await tester.pump();
      expect(shownIds(tester), ['search-red', 'language-spoons']);
      await tester.tap(find.byKey(const ValueKey<String>('activities-minutes-10')));
      await tester.pump();
      expect(find.text(l10n.activitiesCount(5)), findsOneWidget, reason: 'up to 10 minutes');

      // Juntos: categoría y tiempo.
      await tester.tap(search);
      await tester.pump();
      expect(shownIds(tester), ['search-red', 'search-soft']);
    });

    testWidgets('without results, it proposes another search and shows the hints again', (tester) async {
      await open(tester, const ActivitiesScreen());

      await tester.enterText(find.byKey(const ValueKey<String>('activities-search')), 'dinosaurio');
      await tester.pump();
      expect(shownIds(tester), isEmpty);
      expect(find.text(l10n.activitiesCount(0)), findsOneWidget);
      expect(find.text(library.noResults), findsOneWidget);
      await scrollTo(tester, find.byKey(const ValueKey<String>('activities-retry-hint-0')));

      await tester.tap(find.byKey(const ValueKey<String>('activities-retry-hint-0')));
      await tester.pump();
      expect(find.text(library.noResults), findsNothing);
      expect(shownIds(tester), ['sort-socks']);
    });

    testWidgets('builds the cards lazily, as they come into view', (tester) async {
      final ActivityLibrary big = ActivityLibrary.fromJson(
        {
          'activities': [
            for (var index = 0; index < 300; index++)
              {'id': 'art-n$index', 'category': 'art', 'minutes': 5, 'ageFrom': 2, 'recommended': <String>[]},
          ],
        },
        {
          'activities': {
            for (var index = 0; index < 300; index++)
              'art-n$index': {
                'title': 'Idea $index',
                'goal': 'Algo.',
                'materials': ['Papel'],
                'steps': ['Uno.'],
                'variants': ['Otra.'],
                'safety': 'Con un adulto.',
                'tags': <String>[],
              },
          },
          'searchHints': <String>[],
          'noResults': 'Nada.',
        },
      );
      await open(tester, const ActivitiesScreen(), source: FakeActivitySource(big), tall: false);

      expect(find.text(l10n.activitiesCount(300)), findsOneWidget);
      expect(shownIds(tester).length, lessThan(30));
    });
  });

  group('an activity', () {
    testWidgets('shows every part, with its own safety note highlighted', (tester) async {
      final Activity activity = library.byId('art-water')!;
      await open(tester, ActivityScreen(activity: activity, library: library));

      expect(find.text('Pintar con agua'), findsOneWidget);
      expect(find.text('Arte · 30 min · Desde 2 años'), findsOneWidget);
      expect(find.text(l10n.activitiesGoal), findsOneWidget);
      expect(find.text(activity.goal), findsOneWidget);
      expect(find.text(activity.safety), findsOneWidget);
      final DecoratedBox safetyBox = tester.widget<DecoratedBox>(find
          .descendant(of: find.byKey(const ValueKey<String>('activity-safety')), matching: find.byType(DecoratedBox))
          .first);
      expect((safetyBox.decoration as BoxDecoration).color, AppPalette.amber.withValues(alpha: 0.18));
      for (final String text in [...activity.materials, ...activity.variants, ...activity.steps]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      for (var number = 1; number <= activity.steps.length; number++) {
        expect(find.text('$number'), findsOneWidget);
      }
      // Los encabezados, en orden.
      final List<double> tops = [
        for (final String key in ['activity-goal', 'activity-materials', 'activity-steps', 'activity-variants'])
          tester.getTopLeft(find.byKey(ValueKey<String>(key))).dy,
      ];
      expect(tops, orderedEquals([...tops]..sort()));
      expect(find.text(l10n.activitiesKeepPlaying), findsOneWidget);
      expect(shownIds(tester), library.recommendedFor(activity).map((other) => other.id));
      expect(shownIds(tester), ['search-red', 'sort-socks', 'move-cushions']);
    });

    testWidgets('a recommended one opens its own screen, and back returns', (tester) async {
      await open(tester, ActivityScreen(activity: library.byId('art-water')!, library: library));

      await scrollTo(tester, card('sort-socks'));
      await tester.tap(card('sort-socks'));
      await settle(tester);
      expect(find.byKey(const ValueKey<String>('activity-screen-sort-socks')), findsOneWidget);
      expect(find.text('Parejas de calcetines').hitTestable(), findsOneWidget);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await settle(tester);
      expect(find.byKey(const ValueKey<String>('activity-screen-art-water')).hitTestable(), findsOneWidget);
    });

    testWidgets('a card of the section opens its activity', (tester) async {
      await open(tester, const ActivitiesScreen());
      await tester.tap(card('sort-socks'));
      await settle(tester);
      expect(find.byKey(const ValueKey<String>('activity-screen-sort-socks')), findsOneWidget);
    });
  });

  group('not play time (P9)', () {
    PlayTimeCubit playTime(WidgetTester tester) => tester.element(find.byType(Navigator)).read<PlayTimeCubit>();

    testWidgets('the section and an activity do not count as play time while open', (tester) async {
      await open(tester, const ActivitiesScreen());
      expect(playTime(tester).state.inAdultArea, isTrue);

      await tester.tap(card('sort-socks'));
      await settle(tester);
      expect(playTime(tester).state.inAdultArea, isTrue);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await settle(tester);
      expect(playTime(tester).state.inAdultArea, isTrue, reason: 'the section is still open');

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await settle(tester);
      expect(playTime(tester).state.inAdultArea, isFalse);
    });
  });

  group('the rest screen (D4)', () {
    testWidgets('opens the section without the adults challenge', (tester) async {
      await tester.pumpWidget(localizedApp(activities: FakeActivitySource(library), home: const RestScreen()));
      final Finder button = find.byKey(const ValueKey<String>('rest-activities'));
      expect(find.descendant(of: button, matching: find.text(l10n.activitiesTitle)), findsOneWidget);

      await tester.ensureVisible(button);
      await tester.tap(button);
      await settle(tester);
      expect(find.byKey(const ValueKey<String>('activities-screen')), findsOneWidget);
      expect(find.text(l10n.activitiesSafetyWarning), findsOneWidget);
    });

    testWidgets('keeps the cream colour at night', (tester) async {
      await tester.pumpWidget(localizedApp(home: const RestScreen(kind: RestKind.night)));
      final TextButton button = tester.widget<TextButton>(find.byKey(const ValueKey<String>('rest-activities')));
      expect(button.style?.foregroundColor?.resolve({}), AppPalette.warmCream);
    });
  });
}
