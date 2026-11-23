import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:toddler_logic/main.dart' as app;
import 'package:toddler_logic/presentation/screens/activities_screen.dart';
import 'package:toddler_logic/presentation/screens/activity_screen.dart';
import 'package:toddler_logic/presentation/screens/main_menu_screen.dart';
import 'package:toddler_logic/presentation/widgets/game_header.dart';

/// Prueba rápida de funcionamiento en un emulador o un teléfono (TD-015,
/// SPECIFICATION §5): la app real, con su Hive y su motor gráfico, abre el
/// menú, entra y sale de los cuatro juegos y de las actividades sin pantallas
/// y llega al desafío de la Zona de Padres. Se ejecuta con `tool/smoke.ps1` en los emuladores de la versión más
/// antigua (Android 8.0, API 26) y la más reciente.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// El menú tiene animaciones y relojes: no se asienta nunca del todo.
  Future<void> wait(WidgetTester tester, [Duration time = const Duration(seconds: 2)]) async {
    final DateTime end = DateTime.now().add(time);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// «Atrás» dos veces seguidas: los juegos protegen la salida (D-025).
  Future<void> leaveGame(WidgetTester tester) async {
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.binding.handlePopRoute();
    await wait(tester, const Duration(seconds: 2));
  }

  testWidgets('menu, the four games and the parents gate', (tester) async {
    app.main();
    // En un emulador lento el primer arranque tarda: se espera al menú, como mucho 45 s.
    final DateTime limit = DateTime.now().add(const Duration(seconds: 45));
    while (find.byType(MainMenuScreen).evaluate().isEmpty && DateTime.now().isBefore(limit)) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await wait(tester);
    expect(find.byType(MainMenuScreen), findsOneWidget);

    for (final String game in ['memory', 'shadows', 'odd-one-out', 'vehicles']) {
      final Finder card = find.byKey(ValueKey<String>('menu-$game'));
      await tester.ensureVisible(card);
      await tester.tap(card);
      await wait(tester, const Duration(seconds: 4));
      expect(find.byType(GameHeader), findsOneWidget, reason: '$game opens with its header');
      expect(find.byKey(const ValueKey<String>('game-moves-counter')), findsOneWidget, reason: '$game shows its moves');
      await leaveGame(tester);
      expect(find.byType(MainMenuScreen), findsOneWidget, reason: 'back to the menu from $game');
    }

    // Actividades sin pantallas (HU-047): la sección y una actividad.
    final Finder activities = find.byKey(const ValueKey<String>('menu-activities'));
    await tester.ensureVisible(activities);
    await tester.tap(activities);
    await wait(tester, const Duration(seconds: 3));
    expect(find.byType(ActivitiesScreen), findsOneWidget, reason: 'the activities section opens');
    final Finder card = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> && (widget.key! as ValueKey<String>).value.startsWith('activity-card-'),
    );
    // En una pantalla pequeña los filtros ocupan todo: la lista solo se
    // construye al bajar hasta ella.
    for (var i = 0; i < 8 && card.evaluate().isEmpty; i++) {
      await tester.drag(find.byKey(const ValueKey<String>('activities-list')), const Offset(0, -300));
      await wait(tester, const Duration(milliseconds: 500));
    }
    expect(card, findsWidgets, reason: 'with its activities');
    await tester.ensureVisible(card.first);
    await wait(tester, const Duration(milliseconds: 500));
    await tester.tap(card.first);
    await wait(tester);
    expect(find.byType(ActivityScreen), findsOneWidget, reason: 'an activity opens');
    await tester.binding.handlePopRoute();
    await wait(tester, const Duration(seconds: 1));
    await tester.binding.handlePopRoute();
    await wait(tester);
    expect(find.byType(MainMenuScreen), findsOneWidget, reason: 'back to the menu from the activities');

    final Finder parents = find.byKey(const ValueKey<String>('menu-parents-zone'));
    await tester.ensureVisible(parents);
    await tester.tap(parents);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(parents);
    await wait(tester);
    expect(find.byKey(const ValueKey<String>('parental-gate-back')), findsOneWidget, reason: 'the parents gate opens');
  });
}
