import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/screens/parents_zone_screen.dart';
import 'package:toddler_logic/presentation/widgets/adult_session_guard.dart';

import '../l10n_test_support.dart';

void main() {
  testWidgets('shows the title, the way back and the screen pinning instructions (HU-004 P4)', (tester) async {
    await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));

    expect(find.text('Zona de Padres'), findsOneWidget);
    expect(find.text('Volver al menú'), findsOneWidget);

    final section = find.byKey(const ValueKey<String>('parents-zone-screen-pinning'));
    await tester.ensureVisible(section);
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
    expect(find.byType(Card), findsOneWidget);
  });

  testWidgets('is protected by the adult session guard (R7)', (tester) async {
    await tester.pumpWidget(localizedApp(home: const ParentsZoneScreen()));

    expect(find.byType(AdultSessionGuard), findsOneWidget);
  });
}
