import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';

import 'presentation/memory_game_test_support.dart';
import 'presentation/l10n_test_support.dart';

void main() {
  setUpAll(() {
    registerMemoryGameFallbacks();
  });

  group('ToddlerLogicApp', () {
    late MockPersistenceRepository repository;

    setUp(() {
      repository = MockPersistenceRepository();
      stubPersistenceRepository(repository);
    });

    testWidgets('shows the main menu with a single memory game button', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      expect(find.text('ToddlerLogic'), findsOneWidget);
      expect(find.text('Memoria'), findsOneWidget);
      expect(find.text('Encuentra las parejas'), findsOneWidget);
      expect(find.text('Zona de Padres'), findsOneWidget);
    });

    // TD-006: sin mascota ni iconos de juegos hasta definir la identidad visual (HU-013).
    testWidgets('does not show the mascot or game icons in the menu', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      for (final icon in ['🧸', '🚜', '🌴']) {
        expect(find.text(icon), findsNothing, reason: '$icon should not be shown');
      }
    });

    testWidgets('shows a coming-soon notice for the parents zone', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      await tester.tap(find.text('Zona de Padres'));
      await tester.pump();

      expect(find.text('🔒 Zona de padres (Próximamente)'), findsOneWidget);
    });

    testWidgets('opens the memory game at the saved level', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      await tester.tap(find.text('Memoria'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(MemoryGameScreen), findsOneWidget);
      expect(find.byIcon(Icons.question_mark_rounded), findsNWidgets(4));
    });
  });
}
