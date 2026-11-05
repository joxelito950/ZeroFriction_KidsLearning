import 'package:flutter/material.dart';
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
}
