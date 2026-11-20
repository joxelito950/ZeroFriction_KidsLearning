import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:toddler_logic/main.dart' as app;
import 'package:toddler_logic/presentation/screens/main_menu_screen.dart';
import 'package:toddler_logic/presentation/widgets/game_header.dart';

/// Prueba rápida de funcionamiento en un emulador o un teléfono (TD-015,
/// SPECIFICATION §5): la app real, con su Hive y su motor gráfico, abre el
/// menú, entra y sale de los cuatro juegos y llega al desafío de la Zona de
/// Padres. Se ejecuta con `tool/smoke.ps1` en los emuladores de la versión más
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
    await wait(tester, const Duration(seconds: 6));
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

    final Finder parents = find.byKey(const ValueKey<String>('menu-parents-zone'));
    await tester.ensureVisible(parents);
    await tester.tap(parents);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(parents);
    await wait(tester);
    expect(find.byKey(const ValueKey<String>('parental-gate-back')), findsOneWidget, reason: 'the parents gate opens');
  });
}
