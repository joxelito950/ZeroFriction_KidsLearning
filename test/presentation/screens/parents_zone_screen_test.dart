import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/entities/app_language.dart';
import 'package:toddler_logic/presentation/screens/parents_zone_screen.dart';
import 'package:toddler_logic/presentation/widgets/adult_session_guard.dart';

import '../l10n_test_support.dart';

void main() {
  testWidgets('shows the title, the way back and the screen pinning instructions (HU-004 P4)', (tester) async {
    await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));

    expect(find.text('Zona de Padres'), findsOneWidget);
    expect(find.text('Volver al menú'), findsOneWidget);

    final section = find.byKey(const ValueKey<String>('parents-zone-screen-pinning'));
    // La lista solo construye lo que se ve: se desplaza hasta la sección.
    await tester.scrollUntilVisible(section, 200);
    expect(find.descendant(of: section, matching: find.text('Mantener la app en pantalla')), findsOneWidget);
    for (final step in ['1', '2', '3']) {
      expect(find.descendant(of: section, matching: find.text(step)), findsOneWidget);
    }
    expect(find.textContaining('«Fijar aplicaciones»'), findsWidgets);
    expect(find.text('Los nombres y los pasos pueden cambiar según la marca del teléfono.'), findsOneWidget);
  });

  testWidgets('has no coming-soon sections or purchases (P4, D-028)', (tester) async {
    await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));

    expect(find.textContaining('Próximamente'), findsNothing);
    expect(find.byKey(const ValueKey<String>('parents-zone-language')), findsOneWidget);
    await tester.scrollUntilVisible(find.byKey(const ValueKey<String>('parents-zone-screen-pinning')), 200);
    expect(find.byType(Card, skipOffstage: false), findsNWidgets(2), reason: 'language and screen pinning only');
  });

  testWidgets('lists the 9 languages in their own names, without flags, with the current one marked (HU-012 criterio 1)',
      (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));

    final section = find.byKey(const ValueKey<String>('parents-zone-language'));
    expect(find.descendant(of: section, matching: find.text('Idioma')), findsOneWidget);
    for (final code in AppLanguage.supported) {
      final tile = find.byKey(ValueKey<String>('language-$code'));
      await tester.scrollUntilVisible(tile, 100);
      expect(find.descendant(of: tile, matching: find.text(AppLanguage.nativeNames[code]!)), findsOneWidget);
      expect(tester.widget<ListTile>(tile).selected, code == 'es', reason: code);
    }
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.bySemanticsLabel('العربية'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('is protected by the adult session guard (R7)', (tester) async {
    await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));

    expect(find.byType(AdultSessionGuard), findsOneWidget);
  });
}
