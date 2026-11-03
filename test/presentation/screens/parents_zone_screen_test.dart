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
    await tester.scrollUntilVisible(find.byKey(const ValueKey<String>('parents-zone-privacy')), 200);
    expect(find.byType(Card, skipOffstage: false), findsNWidgets(3), reason: 'language, screen pinning and privacy only');
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

  group('privacy (HU-014 R5, criterio 3)', () {
    Future<Finder> openPrivacy(WidgetTester tester, {Locale locale = testLocale}) async {
      await tester.pumpWidget(localizedApp(locale: locale, home: const ParentsZoneScreen()));
      final toggle = find.byKey(const ValueKey<String>('parents-zone-privacy-toggle'));
      await tester.scrollUntilVisible(toggle, 200);
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
      await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));
      await tester.scrollUntilVisible(find.byKey(const ValueKey<String>('parents-zone-privacy')), 200);

      expect(find.text('Privacidad'), findsOneWidget);
      expect(find.text('ToddlerLogic no recoge ningún dato: todo se queda en este teléfono.'), findsOneWidget);
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

  testWidgets('is protected by the adult session guard (R7)', (tester) async {
    await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));

    expect(find.byType(AdultSessionGuard), findsOneWidget);
  });
}
