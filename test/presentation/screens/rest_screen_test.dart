import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/screens/rest_screen.dart';

import '../l10n_test_support.dart';

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(testLocale);

  // En el moto g55 el título cabe en una línea y la columna se encogía al
  // inicio de la pantalla; con la fuente de los tests el título se parte y
  // ocupa todo el ancho, así que se reduce el texto para que quepa.
  testWidgets('keeps its content centred even when the texts are short', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(localizedApp(home: const RestScreen()));

    final double centre = tester.getRect(find.byType(SingleChildScrollView)).center.dx;
    for (final finder in [
      find.text(l10n.restTitle),
      find.text(l10n.restSubtitle),
      find.byIcon(Icons.bedtime_rounded),
      find.byKey(const ValueKey<String>('rest-parents-zone')),
    ]) {
      expect(tester.getCenter(finder).dx, moreOrLessEquals(centre, epsilon: 1));
    }
  });

  // Reportado en la prueba cerrada: al acabar el tiempo no había salida directa.
  testWidgets('offers a direct exit that closes the app, as the menu does', (tester) async {
    int closeRequests = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') closeRequests++;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(localizedApp(home: const RestScreen()));
    final Finder exit = find.byKey(const ValueKey<String>('rest-exit'));
    await tester.ensureVisible(exit);
    expect(find.descendant(of: exit, matching: find.text(l10n.menuExit)), findsOneWidget);
    await tester.tap(exit);
    await tester.pump();
    expect(closeRequests, 1);
  });
}
